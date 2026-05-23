import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitab_mandi/features/auth/view/auth_view.dart';
import 'package:kitab_mandi/features/dashboard/view/dashboard_view.dart';

class WrapperView extends StatelessWidget {
  const WrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          ///  LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          ///  NOT LOGGED IN
          if (!snapshot.hasData) {
            return AuthView();
          }

          final user = snapshot.data!;

          /// 🔥 CHECK FIRESTORE PROFILE
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get(),
            builder: (context, snap) {
              /// 🔄 LOADING
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              /// 📄 DATA
              final data = snap.data?.data() as Map<String, dynamic>?;

              ///  PROFILE NOT COMPLETE
              if (data == null ||
                  data["phone"] == null ||
                  data["phone"].toString().isEmpty) {
                return AuthView(); // 🔥 stay on auth
              }

              ///  PROFILE COMPLETE
              return const DashboardView();
            },
          );
        },
      ),
    );
  }
}
