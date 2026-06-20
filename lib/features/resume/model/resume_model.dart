import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Generated data from Claude ───────────────────────────────────────────────

class ResumeContact {
  final String name, email, phone, location;
  final String? linkedin, github;

  const ResumeContact({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.linkedin,
    this.github,
  });

  factory ResumeContact.fromMap(Map<String, dynamic> m) => ResumeContact(
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        phone: m['phone'] ?? '',
        location: m['location'] ?? '',
        linkedin: m['linkedin'],
        github: m['github'],
      );
}

class ResumeEduItem {
  final String degree, institution, year;
  final String? gpa;

  const ResumeEduItem({
    required this.degree,
    required this.institution,
    required this.year,
    this.gpa,
  });

  factory ResumeEduItem.fromMap(Map<String, dynamic> m) => ResumeEduItem(
        degree: m['degree'] ?? '',
        institution: m['institution'] ?? '',
        year: m['year'] ?? '',
        gpa: m['gpa'],
      );
}

class ResumeSkills {
  final List<String> technical, soft;
  const ResumeSkills({required this.technical, required this.soft});

  factory ResumeSkills.fromMap(Map<String, dynamic> m) => ResumeSkills(
        technical: List<String>.from(m['technical'] ?? []),
        soft: List<String>.from(m['soft'] ?? []),
      );
}

class ResumeExpItem {
  final String title, company, duration;
  final List<String> bullets;

  const ResumeExpItem({
    required this.title,
    required this.company,
    required this.duration,
    required this.bullets,
  });

  factory ResumeExpItem.fromMap(Map<String, dynamic> m) => ResumeExpItem(
        title: m['title'] ?? '',
        company: m['company'] ?? '',
        duration: m['duration'] ?? '',
        bullets: List<String>.from(m['bullets'] ?? []),
      );
}

class ResumeProjItem {
  final String title, tech;
  final String? link;
  final List<String> bullets;

  const ResumeProjItem({
    required this.title,
    required this.tech,
    this.link,
    required this.bullets,
  });

  factory ResumeProjItem.fromMap(Map<String, dynamic> m) => ResumeProjItem(
        title: m['title'] ?? '',
        tech: m['tech'] ?? '',
        link: m['link'],
        bullets: List<String>.from(m['bullets'] ?? []),
      );
}

class GeneratedResume {
  final ResumeContact contact;
  final String summary;
  final List<ResumeEduItem> education;
  final ResumeSkills skills;
  final List<ResumeExpItem> experience;
  final List<ResumeProjItem> projects;
  final List<String> certifications;
  final List<String> keywordsMatched;

  const GeneratedResume({
    required this.contact,
    required this.summary,
    required this.education,
    required this.skills,
    required this.experience,
    required this.projects,
    required this.certifications,
    required this.keywordsMatched,
  });

  factory GeneratedResume.fromMap(Map<String, dynamic> m) {
    final edu = (m['education'] as List?)
            ?.map((e) => ResumeEduItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final exp = (m['experience'] as List?)
            ?.map((e) => ResumeExpItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final proj = (m['projects'] as List?)
            ?.map((e) => ResumeProjItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return GeneratedResume(
      contact: ResumeContact.fromMap(
          Map<String, dynamic>.from(m['contact'] ?? {})),
      summary: m['summary'] ?? '',
      education: edu,
      skills: ResumeSkills.fromMap(
          Map<String, dynamic>.from(m['skills'] ?? {})),
      experience: exp,
      projects: proj,
      certifications: List<String>.from(m['certifications'] ?? []),
      keywordsMatched: List<String>.from(m['keywords_matched'] ?? []),
    );
  }
}

// ─── Firestore record ─────────────────────────────────────────────────────────

class ResumeRecord {
  final String id;
  final DateTime createdAt;
  final String templateId;
  final GeneratedResume data;

  const ResumeRecord({
    required this.id,
    required this.createdAt,
    required this.templateId,
    required this.data,
  });

  factory ResumeRecord.fromDoc(Map<String, dynamic> m, String id) {
    final ts = m['createdAt'];
    final dt = ts is Timestamp ? ts.toDate() : DateTime.now();
    return ResumeRecord(
      id: id,
      createdAt: dt,
      templateId: m['templateId'] ?? 'classic',
      data: GeneratedResume.fromMap(
          Map<String, dynamic>.from(m['generatedData'] ?? {})),
    );
  }
}

// ─── Usage info ───────────────────────────────────────────────────────────────

class ResumeUsage {
  final int usedCount;
  final int maxCount;
  final bool isUnlimited;

  const ResumeUsage({
    required this.usedCount,
    required this.maxCount,
    required this.isUnlimited,
  });

  bool get canGenerate => isUnlimited || usedCount < maxCount;

  String get limitLabel {
    if (isUnlimited) return 'Unlimited';
    return '$usedCount / $maxCount used';
  }
}
