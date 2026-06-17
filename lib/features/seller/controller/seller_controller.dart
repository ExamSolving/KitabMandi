import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/services/location_service.dart';
import 'package:kitab_mandi/core/utils/app_snackbar.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/seller/view/ad_posted_sheet.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/features/listing/domain/repositories/i_listing_repository.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class SellerController extends GetxController {
  final IListingRepository _listingRepo;
  final IAuthRepository _authRepo;

  SellerController(this._listingRepo, this._authRepo);

  final _picker = ImagePicker();

  // ── Form ──────────────────────────────────────────────────────────────────
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  ListingModel? listingModel;
  final RxBool isEdit = false.obs;
  String? listingId;
  final List<String> removedImageUrls = [];

  // ── Location ──────────────────────────────────────────────────────────────
  final RxString state = ''.obs;
  final RxString city = ''.obs;
  final RxString locality = ''.obs;
  final RxString subLocality = ''.obs;
  final RxString postalCode = ''.obs;
  final RxDouble lat = 0.0.obs;
  final RxDouble long = 0.0.obs;
  final RxString fullAddress = ''.obs;

  final RxBool isDetectingLocation = false.obs;
  final RxBool isUploading = false.obs;

  // ── Category ──────────────────────────────────────────────────────────────
  final RxList categories = [].obs;
  final RxString selectedMain = ''.obs;
  final RxString selectedSub = ''.obs;
  final RxString selectedChild = ''.obs;

  List get subCategories {
    final main =
        categories.firstWhereOrNull((e) => e['name'] == selectedMain.value);
    return main?['subcategories'] ?? [];
  }

  List<Map<String, dynamic>> get childCategories {
    final sub = subCategories.firstWhereOrNull(
      (e) => e['name'] == selectedSub.value,
    );
    final children = sub?['children'];
    if (children is List) {
      return children.expand<Map<String, dynamic>>((e) {
        if (e is List) return e.map((item) => Map<String, dynamic>.from(item));
        if (e is Map) return [Map<String, dynamic>.from(e)];
        return [];
      }).toList();
    }
    return [];
  }

  String get subTitle {
    if (selectedMain.value == 'School Books') return 'Board';
    if (selectedMain.value == 'Academic Books') return 'Stream';
    if (selectedMain.value == 'Competitive Exams') return 'Exam Type';
    return 'Sub Category';
  }

  String get childTitle {
    if (selectedMain.value == 'School Books') return 'Class';
    if (selectedMain.value == 'Academic Books') return 'Branch';
    if (selectedMain.value == 'Competitive Exams') return 'Exam';
    return 'Type';
  }

  // ── Condition ─────────────────────────────────────────────────────────────
  final RxString selectedCondition = ''.obs;
  final List<String> conditions = ['New', 'Like New', 'Used'];

  // ── Images ────────────────────────────────────────────────────────────────
  final RxList<String> images = <String>[].obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadCategories();

    if (Get.arguments != null) {
      final arg = Get.arguments;
      listingModel = arg['listing'] as ListingModel?;

      city.value = listingModel?.location['city'] ?? '';
      state.value = listingModel?.location['state'] ?? '';
      subLocality.value = listingModel?.location['subLocality'] ?? '';
      postalCode.value = listingModel?.location['postalCode'] ?? '';
      lat.value = listingModel?.location['lat'] ?? 0.0;
      long.value = listingModel?.location['long'] ?? 0.0;
      fullAddress.value =
          '${subLocality.value}, ${locality.value}, ${city.value}, '
                  '${state.value} - ${postalCode.value}'
              .replaceAll(RegExp(r'(, )+'), ', ')
              .replaceAll(RegExp(r'^, |, $'), '');
      isEdit.value = true;
      listingId = listingModel!.id;
      _prefillData();
    }
  }

  Future<void> loadCategories() async {
    final data = await rootBundle.loadString('assets/data/categories.json');
    categories.value = (json.decode(data) as Map<String, dynamic>)['categories']
        as List;
  }

  void _prefillData() {
    if (listingModel == null) return;
    titleController.text = listingModel!.title;
    priceController.text = listingModel!.price.toString();
    descriptionController.text = listingModel!.description;

    final cat = listingModel!.category;
    selectedMain.value = cat['main'] ?? '';
    selectedSub.value = cat['sub'] ?? '';
    selectedChild.value = cat['child'] ?? '';
    selectedCondition.value = listingModel!.condition;
    images.assignAll(listingModel!.images);
  }

  // ── Image picker ──────────────────────────────────────────────────────────
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    if (images.length >= 3) {
      AppSnackbar.error('Max 3 images allowed');
      return;
    }
    final img = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (img != null) images.add(img.path);
  }

  void removeImage(int index) {
    final img = images[index];
    if (img.startsWith('http')) removedImageUrls.add(img);
    images.removeAt(index);
  }

  // ── Location detect ───────────────────────────────────────────────────────
  Future<void> detectLocation() async {
    try {
      isDetectingLocation.value = true;

      // 1. GPS / location service check
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isDetectingLocation.value = false;
        _showLocationServiceDialog();
        return;
      }

      // 2. Permission check
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        isDetectingLocation.value = false;
        _showPermissionDeniedDialog();
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          AppSnackbar.error('Location permission denied');
          return;
        }
      }

      // 3. Fetch location details
      final locationData = await LocationService.getCurrentLocationDetails();
      if (locationData == null) {
        AppSnackbar.error('Could not detect location. Please try again.');
        return;
      }

      city.value = locationData['city'] ?? '';
      state.value = locationData['state'] ?? '';
      locality.value = locationData['locality'] ?? '';
      subLocality.value = locationData['area'] ?? '';
      postalCode.value = locationData['pincode'] ?? '';
      lat.value = locationData['latitude'] as double;
      long.value = locationData['longitude'] as double;
      fullAddress.value = [
        locationData['area'],
        locationData['locality'],
        locationData['city'],
        locationData['state'],
        locationData['pincode'] != null &&
                locationData['pincode'].toString().isNotEmpty
            ? '- ${locationData["pincode"]}'
            : null,
      ]
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .join(', ');
      AppSnackbar.success('Location detected');
    } catch (e) {
      AppSnackbar.error('Location detection failed. Please try again.');
    } finally {
      isDetectingLocation.value = false;
    }
  }

  void _showLocationServiceDialog() {
    final theme = Get.theme;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Location Services Off',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please enable GPS / Location on your device so we can detect your area.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: theme.hintColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Geolocator.openLocationSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Enable GPS',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    final theme = Get.theme;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.location_disabled_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Location Permission Required',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Location permission was denied. Please allow it in App Settings to auto-detect your area.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: theme.hintColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Geolocator.openAppSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Open Settings',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool validate() {
    if (images.isEmpty) return _err('Please upload at least 1 image');
    if (selectedMain.value.isEmpty) return _err('Please select main category');
    if (selectedSub.value.isEmpty) {
      return _err('Please select ${subTitle.toLowerCase()}');
    }
    if (childCategories.isNotEmpty && selectedChild.value.isEmpty) {
      return _err('Please select ${childTitle.toLowerCase()}');
    }
    final title = titleController.text.trim();
    if (title.isEmpty) return _err('Title is required');
    if (title.length < 5) return _err('Title must be at least 5 characters');

    final priceText = priceController.text.trim();
    if (priceText.isEmpty) return _err('Price is required');
    final price = int.tryParse(priceText);
    if (price == null) return _err('Enter valid price');
    if (price <= 0) return _err('Price must be greater than 0');
    if (price > 100000) return _err('Price too high');

    final desc = descriptionController.text.trim();
    if (desc.isEmpty) return _err('Description is required');
    if (desc.length < 10) return _err('Description too short');
    if (selectedCondition.value.isEmpty) return _err('Select item condition');
    if (fullAddress.value.isEmpty) return _err('Please detect location');
    return true;
  }

  bool _err(String msg) {
    AppSnackbar.error(msg);
    return false;
  }

  // ── Upload ────────────────────────────────────────────────────────────────
  Future<void> uploadListing() async {
    if (!validate()) return;

    try {
      isUploading.value = true;

      final user = _authRepo.currentUser;
      if (user == null) return;

      // Fetch seller profile for embedding in the listing document
      final userData = await _authRepo.getUserProfile(user.uid);

      final List<String> finalImages = [];
      for (final img in images) {
        if (img.startsWith('http')) {
          finalImages.add(img);
        } else {
          finalImages.add(await _listingRepo.uploadImage(img));
        }
      }

      final data = {
        'title': titleController.text.trim(),
        'price': int.tryParse(priceController.text) ?? 0,
        'description': descriptionController.text.trim(),
        'category': {
          'main': selectedMain.value,
          'sub': selectedSub.value,
          'child': selectedChild.value,
        },
        'condition': selectedCondition.value,
        'images': finalImages,
        'location': {
          'lat': lat.value,
          'long': long.value,
          'fullAddress': fullAddress.value,
          'city': city.value,
          'state': state.value,
          'locality': locality.value,
          'subLocality': subLocality.value,
          'postalCode': postalCode.value,
        },
        'seller': {
          'uid': user.uid,
          'name': userData?['name'] ?? '',
          'email': user.email ?? '',
        },
      };

      if (isEdit.value && listingId != null) {
        await _listingRepo.updateListing(listingId!, {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Capture before creating so the count is still 0 for first-ever listing
        final isFirstAd = Get.isRegistered<MyAdsController>()
            ? Get.find<MyAdsController>().myAdsList.isEmpty
            : false;

        await _listingRepo.createListing({
          ...data,
          'status': 'active',
          'isSold': false,
          'createdAt': FieldValue.serverTimestamp(),
          'views': 0,
          'viewedBy': [],
        });
        // Stamp the user doc so the dashboard can enforce the 24-hour limit
        // synchronously from the already-loaded userData on the next sell tap.
        await _authRepo.updateLastListingAt(user.uid);
        await Get.find<AuthController>().fetchUserData();

        Get.offAllNamed(AppRoutes.dashboard);

        // Show celebration sheet after the dashboard route is fully rendered.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => showAdPostedSheet(isFirstAd: isFirstAd),
        );
        return;
      }

      Get.offAllNamed(AppRoutes.dashboard);

      if (Get.isRegistered<HomeController>()) {
        final hc = Get.find<HomeController>();
        hc.fetchAllListings();
        hc.fetchTopViewedListings();
      }
      if (Get.isRegistered<MyAdsController>()) {
        Get.find<MyAdsController>().fetchMyAds();
      }
    } catch (e) {
      AppSnackbar.error('Upload failed');
    } finally {
      isUploading.value = false;
    }
  }
}
