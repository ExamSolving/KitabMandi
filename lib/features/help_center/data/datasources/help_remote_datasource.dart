import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class HelpRemoteDataSource {
  final FirebaseFirestore _firestore;

  HelpRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loadConfig() async {
    try {
      final doc = await _firestore
          .collection('help_support')
          .doc('config')
          .collection('settings')
          .doc('main')
          .get();
      return doc.exists ? doc.data() ?? {} : {};
    } catch (e) {
      debugPrint('[Help] loadConfig error: $e');
      return {};
    }
  }

  // Structure: help_support/faq/categories/{categoryId}/items/{id}
  // Item fields: answer (or nswer), question (or uestion), createdAt, order
  Future<List<Map<String, dynamic>>> fetchFaqs() async {
    final tempFaqs = <Map<String, dynamic>>[];

    try {
      final categoriesSnap = await _firestore
          .collection('help_support')
          .doc('faq')
          .collection('categories')
          .get();

      debugPrint('[FAQ] categories: ${categoriesSnap.docs.map((d) => d.id).toList()}');

      for (final catDoc in categoriesSnap.docs) {
        final itemsSnap = await _firestore
            .collection('help_support')
            .doc('faq')
            .collection('categories')
            .doc(catDoc.id)
            .collection('items')
            .get();

        debugPrint('[FAQ] "${catDoc.id}" → ${itemsSnap.docs.length} items');

        for (final item in itemsSnap.docs) {
          final d = item.data();
          debugPrint('[FAQ] item keys: ${d.keys.toList()}');

          // Support both correct spelling and accidental typo (nswer / uestion)
          final question = (d['question'] ?? d['uestion'] ?? '').toString();
          final answer = (d['answer'] ?? d['nswer'] ?? '').toString();

          if (question.isEmpty && answer.isEmpty) continue;

          tempFaqs.add({
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

      debugPrint('[FAQ] total loaded: ${tempFaqs.length}');
    } catch (e) {
      debugPrint('[FAQ] fetchFaqs error: $e');
    }

    return tempFaqs;
  }

  Future<List<Map<String, dynamic>>> fetchUserTickets(String userId) async {
    final snap = await _firestore
        .collection('help_support')
        .doc('tickets')
        .collection('items')
        .where('userId', isEqualTo: userId)
        .get();
    return snap.docs
        .map((doc) => {'ticketId': doc.id, ...doc.data()})
        .toList();
  }

  Future<void> submitTicket({
    required String userId,
    required String userEmail,
    required Map<String, dynamic> data,
  }) async {
    final docRef = _firestore
        .collection('help_support')
        .doc('tickets')
        .collection('items')
        .doc();
    await docRef.set({
      'ticketId': docRef.id,
      'userId': userId,
      'userEmail': userEmail,
      ...data,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTicketStatus(String ticketId, String status) =>
      _firestore
          .collection('help_support')
          .doc('tickets')
          .collection('items')
          .doc(ticketId)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });

  Future<void> deleteTicket(String ticketId) => _firestore
      .collection('help_support')
      .doc('tickets')
      .collection('items')
      .doc(ticketId)
      .delete();
}
