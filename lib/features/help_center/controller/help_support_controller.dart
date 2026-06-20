import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:kitab_mandi/features/help_center/domain/repositories/i_help_repository.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class HelpSupportController extends GetxController {
  final IHelpRepository _helpRepo;
  final IAuthRepository _authRepo;

  HelpSupportController(this._helpRepo, this._authRepo);

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> faqs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userTickets =
      <Map<String, dynamic>>[].obs;

  final RxList<String> categories = <String>[].obs;
  final RxList<String> priorities = <String>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedPriority = ''.obs;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // Hardcoded — not loaded from Firestore so Firestore config can't override them
  static const List<String> _appCategories = [
    'App Bug / Crash',
    'Login & Account',
    'Chat & Messaging',
    'Notifications',
    'UI / UX Issue',
    'Search & Filters',
    'Feature Request',
    'Other',
  ];

  static const List<String> _appPriorities = ['Low', 'Medium', 'High'];

  @override
  void onInit() {
    super.onInit();
    // Set categories immediately — no Firestore dependency
    categories.value = _appCategories;
    priorities.value = _appPriorities;
    selectedCategory.value = _appCategories.first;
    selectedPriority.value = _appPriorities.first;

    fetchFaqs();
    fetchUserTickets();
  }

  // Queries Firestore directly — bypasses the repository/datasource chain
  // to eliminate any silent failure in those layers.
  // Path: help_support/faq/categories/{id}/items/{id}
  // Fields: question (or uestion), answer (or nswer), order
  Future<void> fetchFaqs() async {
    try {
      isLoading.value = true;

      final db = FirebaseFirestore.instance;
      final categoriesSnap = await db
          .collection('help_support')
          .doc('faq')
          .collection('categories')
          .get();

      debugPrint('[FAQ] categories: ${categoriesSnap.docs.map((d) => d.id).toList()}');

      final tempFaqs = <Map<String, dynamic>>[];

      for (final catDoc in categoriesSnap.docs) {
        final itemsSnap = await db
            .collection('help_support')
            .doc('faq')
            .collection('categories')
            .doc(catDoc.id)
            .collection('items')
            .get();

        debugPrint('[FAQ] "${catDoc.id}" → ${itemsSnap.docs.length} items');

        for (final item in itemsSnap.docs) {
          final d = item.data();
          // Handle both correct spelling and typo variants
          final question = '${d['question'] ?? d['uestion'] ?? ''}';
          final answer = '${d['answer'] ?? d['nswer'] ?? ''}';
          if (question.isEmpty && answer.isEmpty) continue;
          tempFaqs.add(<String, dynamic>{
            'id': item.id,
            'category': catDoc.id,
            'question': question,
            'answer': answer,
            'order': (d['order'] as num?)?.toInt() ?? 0,
          });
        }
      }

      tempFaqs.sort((a, b) =>
          ((a['order'] as int?) ?? 0)
              .compareTo((b['order'] as int?) ?? 0));

      debugPrint('[FAQ] total fetched: ${tempFaqs.length}');

      faqs.value = tempFaqs.isNotEmpty ? tempFaqs : _buildFallbackFaqs();
    } catch (e, st) {
      debugPrint('[FAQ] error: $e\n$st');
      faqs.value = _buildFallbackFaqs();
    } finally {
      isLoading.value = false;
    }
  }

  // Returns typed Map<String, dynamic> list — avoids const Map<String,Object> cast issues
  static List<Map<String, dynamic>> _buildFallbackFaqs() => [
        {
          'id': 'f1',
          'question': 'How do I register on KitabMandi?',
          'answer':
              'Tap "Sign Up", enter your name, email, phone number and create a password. Allow location access so we can show you books nearby.',
          'order': 1,
        },
        {
          'id': 'f2',
          'question': 'How do I post a book for sale?',
          'answer':
              'Go to the Sell tab, tap "+", fill in the book title, author, condition and price, then upload photos. Your listing goes live immediately.',
          'order': 2,
        },
        {
          'id': 'f3',
          'question': 'How do I contact a seller?',
          'answer':
              'Open any listing and tap "Chat" to message the seller directly inside the app.',
          'order': 3,
        },
        {
          'id': 'f4',
          'question': 'Is my personal information safe?',
          'answer':
              'Yes. KitabMandi never shares your email or phone number publicly. Only your display name and city appear on your profile.',
          'order': 4,
        },
        {
          'id': 'f5',
          'question': 'I am not receiving notifications. What should I do?',
          'answer':
              'Go to phone Settings → Apps → KitabMandi → Notifications and make sure they are enabled. Also check your internet connection.',
          'order': 5,
        },
        {
          'id': 'f6',
          'question': 'How do I delete my account?',
          'answer':
              'Go to Profile → Settings → Delete Account. Your data will be removed within 7 days. This action cannot be undone.',
          'order': 6,
        },
        {
          'id': 'f7',
          'question': 'What should I do if the app crashes?',
          'answer':
              'Force-close the app and reopen it. If it keeps crashing, reinstall the app or raise a support ticket.',
          'order': 7,
        },
        {
          'id': 'f8',
          'question': 'Can I edit or delete my listing?',
          'answer':
              'Yes. Go to Profile → My Listings, tap the listing and select Edit or Delete.',
          'order': 8,
        },
      ];

  Future<void> fetchUserTickets() async {
    try {
      final uid = _authRepo.currentUser?.uid;
      if (uid == null) return;
      userTickets.value = await _helpRepo.fetchUserTickets(uid);
    } catch (e) {
      debugPrint('[Tickets] error: $e');
    }
  }

  Future<void> submitTicket() async {
    if (titleCtrl.text.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'ticket_enter_title'.tr,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (descCtrl.text.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'ticket_enter_desc'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = _authRepo.currentUser;
      if (user == null) return;

      await _helpRepo.submitTicket(
        userId: user.uid,
        userEmail: user.email ?? '',
        data: {
          'title': titleCtrl.text.trim(),
          'description': descCtrl.text.trim(),
          'category': selectedCategory.value,
          'priority': selectedPriority.value,
        },
      );

      titleCtrl.clear();
      descCtrl.clear();
      selectedCategory.value = _appCategories.first;
      selectedPriority.value = _appPriorities.first;

      await fetchUserTickets();
      Get.snackbar(
        'success'.tr,
        'ticket_submitted_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAndToNamed(AppRoutes.helpSupport);
    } catch (e) {
      Get.snackbar('error'.tr, 'ticket_submit_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      isLoading.value = true;
      final user = _authRepo.currentUser;
      if (user == null) return;
      await _helpRepo.submitTicket(
        userId: user.uid,
        userEmail: user.email ?? '',
        data: {
          'title': title,
          'description': description,
          'category': category,
          'priority': priority,
        },
      );
      await fetchUserTickets();
    } catch (e) {
      Get.snackbar('error'.tr, '${'ticket_submit_failed'.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    try {
      await _helpRepo.updateTicketStatus(ticketId, status);
      await fetchUserTickets();
    } catch (e) {
      Get.snackbar('error'.tr, 'error_generic'.tr);
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    try {
      await _helpRepo.deleteTicket(ticketId);
      userTickets.removeWhere((t) => t['ticketId'] == ticketId);
    } catch (e) {
      Get.snackbar('error'.tr, 'error_generic'.tr);
    }
  }

  Future<void> refreshTickets() => fetchUserTickets();
}
