import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxInt totalListings = 0.obs;
  RxInt soldListings = 0.obs;
  RxInt boughtListings = 0.obs;
  final firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    fetchCountsValue();
    super.onInit();
  }

  Future<void> fetchCountsValue() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    //TOTAL LISTINGS
    final listingSnapshot = await firestore
        .collection("listings")
        .where("seller.uid", isEqualTo: uid)
        .get();
    totalListings.value = listingSnapshot.docs.length;
    //TOTAL SOLD
    final soldSnapshot = await firestore
        .collection("listings")
        .where("seller.uid", isEqualTo: uid)
        .where("isSold", isEqualTo: true)
        .get();
    soldListings.value = soldSnapshot.docs.length;

    //BOUGHT SOLD
    // final soldSnapshot = await firestore
    //     .collection("listings")
    //     .where("seller.id", isEqualTo: uid)
    //     .where("isSold", isEqualTo: TreeSliver.defaultAnimationDuration)
    //     .get();
    boughtListings.value = 0;
  }
}
