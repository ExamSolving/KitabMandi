import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<ListingModel> listings = <ListingModel>[].obs;
  RxList<ListingModel> filteredListings = <ListingModel>[].obs;

  final filterCtrl = Get.put(FilterController());
  final locationCtrl = Get.put(LocationController());

  RxString searchQuery = "".obs;
  RxBool isLoading = true.obs;

  /// 🎯 Radius (KM)
  double radiusKm = 10.0;

  @override
  void onInit() {
    super.onInit();

    /// 🔥 Auto re-filter
    ever(locationCtrl.latitude, (_) => applyFilters());
    ever(locationCtrl.longitude, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());

    _init();
  }

  Future<void> _init() async {
    locationCtrl.loadInitialData();
    listenListings();
  }

  /// 📏 Distance Formula (Haversine)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;

    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// 📡 Firestore Listener
  void listenListings() {
    isLoading.value = true;

    _firestore
        .collection("listings")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
          listings.value = snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data()))
              .toList();
          applyFilters();

          isLoading.value = false;
        });
  }

  /// 🎯 MAIN FILTER (FINAL FIXED)
  void applyFilters() {
    List<ListingModel> temp = List.from(listings);

    final userLat = locationCtrl.latitude.value;
    final userLng = locationCtrl.longitude.value;

    ///  SEARCH
    if (searchQuery.value.isNotEmpty) {
      temp = temp.where((item) {
        return item.title.toLowerCase().contains(
          searchQuery.value.toLowerCase(),
        );
      }).toList();
    }

    ///  CATEGORY
    if (filterCtrl.selectedCategories.isNotEmpty) {
      temp = temp.where((item) {
        return filterCtrl.selectedCategories.contains(item.category);
      }).toList();
    }

    ///  CONDITION
    if (filterCtrl.selectedConditions.isNotEmpty) {
      temp = temp.where((item) {
        return filterCtrl.selectedConditions.contains(item.condition);
      }).toList();
    }

    ///  PRICE
    temp = temp.where((item) {
      return item.price >= filterCtrl.minPrice.value &&
          item.price <= filterCtrl.maxPrice.value;
    }).toList();

    ///  LOCATION FILTER (SAFE + FIXED)
    if (userLat != 0.0 && userLng != 0.0) {
      List<ListingModel> locationFiltered = [];

      for (var item in temp) {
        final loc = item.location;

        final latRaw = loc['lat'];
        final lngRaw = loc['long'];

        final lat = double.tryParse(latRaw.toString());
        final lng = double.tryParse(lngRaw.toString());

        ///  Invalid location → KEEP
        if (lat == null || lng == null) {
          locationFiltered.add(item);
          continue;
        }

        final distance = calculateDistance(userLat, userLng, lat, lng);

        ///  Only remove OUTSIDE radius
        item.distanceKm = distance;
        if (filterCtrl.selectedDistanceKm.value != 0.0) {
          radiusKm = filterCtrl.selectedDistanceKm.value;
        }
        if (distance <= radiusKm) {
          locationFiltered.add(item);
        }
      }

      temp = locationFiltered;
    } else {
      print("⚠️ No user location → showing all listings");
    }

    /// 🔄 SORT
    switch (filterCtrl.selectedSort.value) {
      case "Price: Low to High":
        temp.sort((a, b) => a.price.compareTo(b.price));
        break;
      case "Price: High to Low":
        temp.sort((a, b) => b.price.compareTo(a.price));
        break;
      case "Newest First":
        temp.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );
        break;
    }

    filteredListings.value = temp;

    print("✅ FINAL COUNT: ${filteredListings.length}");
  }

  /// 🔍 Search
  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  /// 🔄 Manual fetch
  Future<void> fetchListings() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection("listings")
          .orderBy("createdAt", descending: true)
          .get();

      listings.value = snapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data()))
          .toList();

      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }
}
