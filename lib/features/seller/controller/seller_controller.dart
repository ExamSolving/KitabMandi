import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/core/utils/app_snackbar.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class SellerController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  //=============All Controllers===================
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  final addressController = TextEditingController();

  final classController = TextEditingController();
  final degreeController = TextEditingController();
  final yearController = TextEditingController();

  ListingModel? listingModel;

  RxBool isEdit = false.obs;
  String? listingId;

  // Track deleted old images
  final List<String> removedImageUrls = [];

  // ================= LOCATION =================
  RxString state = "".obs;
  RxString city = "".obs;
  RxString locality = "".obs;
  RxString subLocality = "".obs;
  RxString postalCode = "".obs;
  RxDouble lat = 0.0.obs;
  RxDouble long = 0.0.obs;

  RxBool isDetectingLocation = false.obs;
  RxBool isUploading = false.obs;

  final myAdsCtrl = Get.find<MyAdsController>();

  String get fullAddress => [
    subLocality.value,
    locality.value,
    city.value,
    state.value,
    postalCode.value,
  ].where((e) => e.isNotEmpty).join(", ");

  set fullAddress(Map<String, dynamic> location) {
    subLocality.value = location["subLocality"] ?? "";
    locality.value = location["locality"] ?? "";
    city.value = location["city"] ?? "";
    state.value = location["state"] ?? "";
    postalCode.value = location["postalCode"] ?? "";
  }

  // ================= CATEGORY =================
  RxString selectedCategory = "".obs;
  final categories = ["Books", "Notes", "Stationery", "Others"];

  // ================= EDUCATION =================
  RxString selectedEducationType = "".obs;
  final educationTypes = [
    "School",
    "College",
    "Competitive Exam",
    "Professional",
  ];

  RxString selectedClass = "".obs;
  RxString selectedDegree = "".obs;
  RxString selectedYear = "".obs;

  final schoolClasses = List.generate(12, (i) => "${i + 1}${_suffix(i + 1)}");

  final degrees = [
    "B.Tech",
    "B.Sc",
    "BA",
    "B.Com",
    "BBA",
    "BCA",
    "M.Tech",
    "M.Sc",
    "MBA",
  ];

  final degreeYears = {
    "B.Tech": ["1st Year", "2nd Year", "3rd Year", "4th Year"],
    "B.Sc": ["1st Year", "2nd Year", "3rd Year"],
    "BA": ["1st Year", "2nd Year", "3rd Year"],
    "B.Com": ["1st Year", "2nd Year", "3rd Year"],
    "BBA": ["1st Year", "2nd Year", "3rd Year"],
    "BCA": ["1st Year", "2nd Year", "3rd Year"],
    "M.Tech": ["1st Year", "2nd Year"],
    "M.Sc": ["1st Year", "2nd Year"],
    "MBA": ["1st Year", "2nd Year"],
  };

  final exams = ["SSC", "UPSC", "NEET", "JEE", "Railway", "Banking"];

  // ================= CONDITION =================
  RxString selectedCondition = "".obs;
  final conditions = ["New", "Like New", "Used"];

  // ================= IMAGES =================
  RxList<String> images = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      final arg = Get.arguments;
      listingModel = arg['listing'];
      isEdit.value = true;
      listingId = listingModel!.id;
      _prefillData();
    }
  }

  void _prefillData() {
    if (listingModel == null) return;

    titleController.text = listingModel!.title;
    priceController.text = listingModel!.price.toString();
    descriptionController.text = listingModel!.description;

    selectedCategory.value = listingModel!.category;
    selectedCondition.value = listingModel!.condition;
    selectedEducationType.value = listingModel!.educationType;
    selectedClass.value = listingModel?.className ?? "";
    selectedDegree.value = listingModel?.degree ?? "";
    selectedYear.value = listingModel?.year ?? "";

    images.assignAll(listingModel!.images);
    fullAddress = listingModel!.location;
  }

  // ================= IMAGE PICK =================
  Future<void> pickImage() async {
    if (images.length >= 3) {
      AppSnackbar.error("Max 3 images allowed");
      return;
    }

    final img = await _picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      images.add(img.path);
    }
  }

  void removeImage(int index) {
    final img = images[index];

    if (img.startsWith("http")) {
      removedImageUrls.add(img);
    }

    images.removeAt(index);
  }

  // ================= LOCATION =================
  Future<void> detectLocation() async {
    try {
      isDetectingLocation.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppSnackbar.error("Enable GPS");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        AppSnackbar.error("Permission permanently denied");
        return;
      }

      final pos = await Geolocator.getCurrentPosition();

      final place = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final p = place.first;

      city.value = p.locality ?? "";
      state.value = p.administrativeArea ?? "";
      locality.value = p.locality ?? "";
      subLocality.value = p.subLocality ?? "";
      postalCode.value = p.postalCode ?? "";

      lat.value = pos.latitude;
      long.value = pos.longitude;
      fullAddress;

      AppSnackbar.success("Location detected");
    } catch (e) {
      AppSnackbar.error("Location failed");
    } finally {
      isDetectingLocation.value = false;
    }
  }

  // ================= IMAGE HELPERS =================
  Future<String> _uploadSingle(File file) async {
    final ref = _storage.ref().child(
      "listings/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _deleteImage(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }

  // ================= VALIDATION =================
  bool validate() {
    if (images.isEmpty) return _err("Add at least one image");
    if (selectedCategory.value.isEmpty) return _err("Select category");
    if (selectedCondition.value.isEmpty) return _err("Select condition");
    if (titleController.text.isEmpty) return _err("Enter title");
    if (priceController.text.isEmpty) return _err("Enter price");
    if (city.value.isEmpty) return _err("Select location");
    return true;
  }

  bool _err(String msg) {
    AppSnackbar.error(msg);
    return false;
  }

  // ================= MAIN SAVE =================
  Future<void> uploadListing() async {
    if (!validate()) return;

    try {
      isUploading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        AppSnackbar.error("Login required");
        return;
      }

      List<String> finalImages = [];

      /// ================= IMAGE UPLOAD =================
      for (var img in images) {
        if (img.startsWith("http")) {
          finalImages.add(img);
        } else {
          final url = await _uploadSingle(File(img));
          finalImages.add(url);
        }
      }

      /// ================= DELETE REMOVED =================
      for (var url in removedImageUrls) {
        await _deleteImage(url);
      }

      /// ================= DATA =================
      final data = {
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "price": int.tryParse(priceController.text) ?? 0,
        "category": selectedCategory.value,
        "educationType": selectedEducationType.value,
        "class": selectedClass.value,
        "degree": selectedDegree.value,
        "year": selectedYear.value,
        "condition": selectedCondition.value,
        "images": finalImages,
        "location": {
          "city": city.value,
          "state": state.value,
          "locality": locality.value,
          "subLocality": subLocality.value,
          "postalCode": postalCode.value,
          "fullAddress": fullAddress,
          "lat": lat.value,
          "long": long.value,
        },
        "updatedAt": FieldValue.serverTimestamp(),
      };

      /// ================= FIRESTORE =================
      if (isEdit.value) {
        await _firestore.collection("listings").doc(listingId).update(data);
        AppSnackbar.success("Listing updated successfully");
      } else {
        final doc = _firestore.collection("listings").doc();
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        final userData = userDoc.data();

        await doc.set({
          ...data,
          "id": doc.id,
          "createdAt": FieldValue.serverTimestamp(),
          "isSold": false,
          "seller": {
            "uid": user.uid,
            "name": userData?["name"] ?? "",
            "email": userData?["email"] ?? "",
            "phone": userData?["phone"] ?? "",
            "photo": userData?["photoUrl"] ?? "",
          },
        });
        AppSnackbar.success("Listing created successfully");
      }
      Get.offAllNamed(AppRoutes.dashboard);

      /// ================= REFRESH HOME =================
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchListings();
      }
      if (Get.isRegistered<MyAdsController>()) {
        await Get.find<MyAdsController>().fetchMyAds();
      }

      /// ================= NAVIGATION =================
      //  ALWAYS GO TO HOME
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      AppSnackbar.error("Something went wrong. Try again.");
    } finally {
      isUploading.value = false;
    }
  }

  // ================= CLEAR =================
  void clear() {
    titleController.clear();
    priceController.clear();
    descriptionController.clear();
    images.clear();
    removedImageUrls.clear();
  }

  static String _suffix(int i) {
    if (i == 1) return "st";
    if (i == 2) return "nd";
    if (i == 3) return "rd";
    return "th";
  }
}
