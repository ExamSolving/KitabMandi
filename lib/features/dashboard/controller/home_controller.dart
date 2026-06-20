import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';

class HomeController extends GetxController {
  final IListingRepository _listingRepo;
  HomeController(this._listingRepo);

  // ── Lists ─────────────────────────────────────────────────────────────────
  final RxList<ListingModel> allListings = <ListingModel>[].obs;
  final RxList<ListingModel> searchedListings = <ListingModel>[].obs;
  final RxList<ListingModel> filteredListings = <ListingModel>[].obs;
  final RxList<ListingModel> popularListingNearYou = <ListingModel>[].obs;

  // ── State ─────────────────────────────────────────────────────────────────
  final locationCtrl = Get.find<LocationController>();
  final filterCtrl = Get.find<FilterController>();
  final searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  // Counts in-flight fetches so isLoading stays true until ALL finish.
  int _pendingLoads = 0;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    ever(locationCtrl.latitude, (_) => _onLocationChanged());
    ever(locationCtrl.longitude, (_) => _onLocationChanged());
    debounce(
      searchQuery,
      (_) => applyAllFilters(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onReady() {
    super.onReady();
    reloadAll();
  }

  void _onLocationChanged() {
    if (locationCtrl.latitude.value == 0.0 ||
        locationCtrl.longitude.value == 0.0) {
      return;
    }
    reloadAll();
  }

  // Called by pull-to-refresh and retry buttons.
  Future<void> reloadAll() async {
    hasError.value = false;
    await Future.wait([fetchTopViewedListings(), fetchAllListings()]);
  }

  // ── Internal load counter ─────────────────────────────────────────────────
  void _beginLoad() {
    _pendingLoads++;
    isLoading.value = true;
  }

  void _endLoad() {
    _pendingLoads = (_pendingLoads - 1).clamp(0, 99);
    if (_pendingLoads == 0) isLoading.value = false;
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void onSearchChanged(String value) => searchQuery.value = value;

  void applySearch() {
    if (searchQuery.value.isEmpty) {
      searchedListings.value = List.from(allListings);
    } else {
      final query = searchQuery.value.toLowerCase();
      searchedListings.value = allListings.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
      }).toList();
    }
  }

  // ── Filter pipeline ───────────────────────────────────────────────────────
  void applyAllFilters() {
    applySearch();
    List<ListingModel> temp = List.from(searchedListings);

    if (filterCtrl.selectedCategory.value.isNotEmpty) {
      temp = temp
          .where((i) => i.mainCategory == filterCtrl.selectedCategory.value)
          .toList();
    }
    if (filterCtrl.selectedSubCategory.value.isNotEmpty) {
      temp = temp
          .where((i) => i.subCategory == filterCtrl.selectedSubCategory.value)
          .toList();
    }
    if (filterCtrl.selectedType.value.isNotEmpty) {
      temp = temp
          .where((i) => i.childCategory == filterCtrl.selectedType.value)
          .toList();
    }
    temp = temp
        .where((i) =>
            i.price >= filterCtrl.minPrice.value &&
            i.price <= filterCtrl.maxPrice.value)
        .toList();

    if (filterCtrl.selectedConditions.isNotEmpty) {
      temp = temp
          .where((i) => filterCtrl.selectedConditions.contains(i.condition))
          .toList();
    }
    // -1.0 = user explicitly chose "Any" (no radius)
    //  0.0 = not set → auto-apply 5 km when location is available
    //  >0  = user-picked radius from filter screen
    final hasLocation = locationCtrl.latitude.value != 0.0 &&
        locationCtrl.longitude.value != 0.0;
    final distanceSetting = filterCtrl.selectedDistanceKm.value;
    if (hasLocation && distanceSetting != -1.0) {
      final radiusKm = distanceSetting > 0 ? distanceSetting : 5.0;
      temp = temp.where((i) {
        return calculateDistance(sellerLat: i.lat, sellerLong: i.long) <=
            radiusKm;
      }).toList();
    }

    if (filterCtrl.selectedSort.value.isNotEmpty) {
      if (filterCtrl.selectedSort.value == 'Price: Low to High') {
        temp.sort((a, b) => a.price.compareTo(b.price));
      } else if (filterCtrl.selectedSort.value == 'Price: High to Low') {
        temp.sort((a, b) => b.price.compareTo(a.price));
      } else if (filterCtrl.selectedSort.value == 'Newest First') {
        // Null-safe sort: listings without createdAt go to the end
        temp.sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
      }
    } else {
      // Default: featured (Pro plan) first → high views → nearest
      temp.sort((a, b) {
        final aFeatured = (a.isFeatured ?? false) ? 0 : 1;
        final bFeatured = (b.isFeatured ?? false) ? 0 : 1;
        if (aFeatured != bFeatured) return aFeatured.compareTo(bFeatured);
        if (a.views != b.views) return b.views.compareTo(a.views);
        final d1 = calculateDistance(sellerLat: a.lat, sellerLong: a.long);
        final d2 = calculateDistance(sellerLat: b.lat, sellerLong: b.long);
        return d1.compareTo(d2);
      });
    }

    filteredListings.value = temp;

    // Keep popular-near-you in sync with the active location radius.
    // Sort: featured (Pro plan) first → high views → normal
    final nearby = nearbyListings();
    nearby.sort((a, b) {
      final aFeatured = (a.isFeatured ?? false) ? 0 : 1;
      final bFeatured = (b.isFeatured ?? false) ? 0 : 1;
      if (aFeatured != bFeatured) return aFeatured.compareTo(bFeatured);
      return b.views.compareTo(a.views);
    });
    popularListingNearYou.value =
        nearby.length > 20 ? nearby.take(20).toList() : nearby;
  }

  // ── Distance ──────────────────────────────────────────────────────────────
  double calculateDistance({
    required double sellerLat,
    required double sellerLong,
  }) {
    final userLat = locationCtrl.latitude.value;
    final userLong = locationCtrl.longitude.value;
    if (userLat == 0.0 || userLong == 0.0) return 0.0;

    const earthRadius = 6371;
    final dLat = (sellerLat - userLat) * pi / 180;
    final dLon = (sellerLong - userLong) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(userLat * pi / 180) *
            cos(sellerLat * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  // Score map for sorting categories by activity within the current location radius.
  // Call inside Obx — reads allListings + location observables as dependencies.
  Map<String, int> categoryPopularityScores() {
    final scores = <String, int>{};
    for (final listing in nearbyListings()) {
      final cat = listing.mainCategory;
      if (cat.isEmpty) continue;
      scores[cat] = (scores[cat] ?? 0) + 10 + listing.views;
    }
    return scores;
  }

  // Count of nearby listings per category (for display badge).
  Map<String, int> categoryListingCounts() {
    final counts = <String, int>{};
    for (final listing in nearbyListings()) {
      final cat = listing.mainCategory;
      if (cat.isEmpty) continue;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }

  // Returns the radius currently being applied (null = no radius filter).
  // Call inside Obx — reads observables from locationCtrl and filterCtrl.
  double? effectiveRadiusKm() {
    final hasLocation = locationCtrl.latitude.value != 0.0 &&
        locationCtrl.longitude.value != 0.0;
    if (!hasLocation) return null;
    final d = filterCtrl.selectedDistanceKm.value;
    if (d == -1.0) return null;
    return d > 0 ? d : 5.0;
  }

  // allListings filtered to the effective location radius only (no other filters).
  // Safe to call inside Obx — reads lat/lng/distance observables as dependencies.
  List<ListingModel> nearbyListings() {
    final hasLocation = locationCtrl.latitude.value != 0.0 &&
        locationCtrl.longitude.value != 0.0;
    if (!hasLocation) return allListings.toList();
    final d = filterCtrl.selectedDistanceKm.value;
    if (d == -1.0) return allListings.toList(); // user chose "Any"
    final radius = d > 0 ? d : 5.0;
    return allListings
        .where((i) =>
            calculateDistance(sellerLat: i.lat, sellerLong: i.long) <= radius)
        .toList();
  }

  // ── Fetches ───────────────────────────────────────────────────────────────
  // fetchTopViewedListings is kept for the parallel load pattern in reloadAll().
  // popularListingNearYou is now primarily maintained by applyAllFilters() so
  // it stays in sync whenever location or filters change without a re-fetch.
  Future<void> fetchTopViewedListings() async {
    _beginLoad();
    try {
      // Nothing to do here — applyAllFilters() (called by fetchAllListings)
      // already computes popularListingNearYou from allListings.
      // This stub keeps the parallel Future.wait() in reloadAll() balanced.
    } catch (_) {
    } finally {
      _endLoad();
    }
  }

  Future<void> fetchAllListings() async {
    _beginLoad();
    try {
      final all = await _listingRepo.getListings();
      final myUid = FirebaseAuth.instance.currentUser?.uid;
      // Hide the current user's own listings from browse/all-listings screens.
      allListings.value = myUid != null
          ? all
              .where((l) => l.seller['uid']?.toString() != myUid)
              .toList()
          : all;
      applyAllFilters();
    } catch (_) {
      hasError.value = true;
    } finally {
      _endLoad();
    }
  }
}
