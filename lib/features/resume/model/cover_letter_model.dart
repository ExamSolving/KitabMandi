import 'package:cloud_firestore/cloud_firestore.dart';

class CoverLetterUsage {
  final int usedCount;
  final int maxCount;

  const CoverLetterUsage({required this.usedCount, required this.maxCount});

  bool get canGenerate => usedCount < maxCount;
  int get remaining => (maxCount - usedCount).clamp(0, maxCount);
}

class CoverLetterRecord {
  final String id;
  final String resumeId;
  final String jobTitle;
  final String companyName;
  final String letterText;
  final DateTime createdAt;
  final String? aiModel;

  const CoverLetterRecord({
    required this.id,
    required this.resumeId,
    required this.jobTitle,
    required this.companyName,
    required this.letterText,
    required this.createdAt,
    this.aiModel,
  });

  factory CoverLetterRecord.fromDoc(Map<String, dynamic> m, String id) {
    final ts = m['createdAt'];
    return CoverLetterRecord(
      id: id,
      resumeId: m['resumeId'] as String? ?? '',
      jobTitle: m['jobTitle'] as String? ?? '',
      companyName: m['companyName'] as String? ?? '',
      letterText: m['letterText'] as String? ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      aiModel: m['aiModel'] as String?,
    );
  }
}
