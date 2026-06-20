import 'package:cloud_firestore/cloud_firestore.dart';

class CoverLetterRecord {
  final String id;
  final String resumeId;
  final String jobTitle;
  final String companyName;
  final String letterText;
  final DateTime createdAt;

  const CoverLetterRecord({
    required this.id,
    required this.resumeId,
    required this.jobTitle,
    required this.companyName,
    required this.letterText,
    required this.createdAt,
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
    );
  }
}
