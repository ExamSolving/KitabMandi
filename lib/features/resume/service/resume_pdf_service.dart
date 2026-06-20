import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:kitab_mandi/features/resume/model/resume_model.dart';

class ResumePdfService {
  // ─── Public entry point ────────────────────────────────────────────────────
  static Future<Uint8List> generate(ResumeRecord record) async {
    if (record.templateId == 'modern') {
      return _buildModern(record.data);
    }
    return _buildClassic(record.data);
  }

  // ─── Shared palette ────────────────────────────────────────────────────────
  static const _green = PdfColor.fromInt(0xFF1F5E3B);
  static const _greenLight = PdfColor.fromInt(0xFFE8F5EE);
  static const _darkGrey = PdfColor.fromInt(0xFF1A1D23);
  static const _midGrey = PdfColor.fromInt(0xFF555A66);
  static const _lightGrey = PdfColor.fromInt(0xFFEEEEEE);
  static const _white = PdfColors.white;

  // ─── Helper widgets ────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String text, {PdfColor color = _green}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(text,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: color,
              letterSpacing: 1.2,
            )),
        pw.SizedBox(height: 3),
        pw.Container(height: 1.5, color: color),
        pw.SizedBox(height: 6),
      ],
    );
  }

  static pw.Widget _bullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3, left: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ',
              style: pw.TextStyle(fontSize: 9, color: _green,
                  fontWeight: pw.FontWeight.bold)),
          pw.Expanded(
            child: pw.Text(text,
                style: pw.TextStyle(fontSize: 9, color: _darkGrey,
                    lineSpacing: 1.4)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _chip(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const pw.EdgeInsets.only(right: 5, bottom: 5),
      decoration: pw.BoxDecoration(
        color: _greenLight,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 8.5, color: _green,
              fontWeight: pw.FontWeight.bold)),
    );
  }

  // ─── Classic template ─────────────────────────────────────────────────────

  static Future<Uint8List> _buildClassic(GeneratedResume r) async {
    final doc = pw.Document();
    final c = r.contact;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
        build: (ctx) => [
          // Header
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(c.name,
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold,
                      color: _darkGrey)),
              pw.SizedBox(height: 4),
              pw.Wrap(
                children: [
                  _contactChip(c.email),
                  _contactChip(c.phone),
                  _contactChip(c.location),
                  if (c.linkedin != null) _contactChip(c.linkedin!),
                  if (c.github != null) _contactChip(c.github!),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(height: 2, color: _green),
              pw.SizedBox(height: 10),
            ],
          ),

          // Summary
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('PROFESSIONAL SUMMARY'),
              pw.Text(r.summary,
                  style: pw.TextStyle(fontSize: 9.5, color: _midGrey,
                      lineSpacing: 1.5)),
              pw.SizedBox(height: 12),
            ],
          ),

          // Skills
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('SKILLS'),
              pw.Text('Technical Skills',
                  style: pw.TextStyle(fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold, color: _darkGrey)),
              pw.SizedBox(height: 4),
              pw.Wrap(
                  children: r.skills.technical.map(_chip).toList()),
              if (r.skills.soft.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Text('Soft Skills',
                    style: pw.TextStyle(fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold, color: _darkGrey)),
                pw.SizedBox(height: 4),
                pw.Wrap(children: r.skills.soft.map(_chip).toList()),
              ],
              pw.SizedBox(height: 12),
            ],
          ),

          // Education
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('EDUCATION'),
              ...r.education.map((e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(e.degree,
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: _darkGrey)),
                            pw.Text(e.institution,
                                style: pw.TextStyle(
                                    fontSize: 9.5, color: _midGrey)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(e.year,
                                style: pw.TextStyle(
                                    fontSize: 9, color: _midGrey)),
                            if (e.gpa != null)
                              pw.Text('GPA: ${e.gpa}',
                                  style: pw.TextStyle(
                                      fontSize: 9, color: _green)),
                          ],
                        ),
                      ],
                    ),
                  )),
              pw.SizedBox(height: 8),
            ],
          ),

          // Experience
          if (r.experience.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('EXPERIENCE'),
                ...r.experience.map((e) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(e.title,
                                  style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: _darkGrey)),
                              pw.Text(e.duration,
                                  style: pw.TextStyle(
                                      fontSize: 9, color: _midGrey)),
                            ],
                          ),
                          pw.Text(e.company,
                              style: pw.TextStyle(
                                  fontSize: 9.5, color: _green,
                                  fontStyle: pw.FontStyle.italic)),
                          pw.SizedBox(height: 4),
                          ...e.bullets.map(_bullet),
                        ],
                      ),
                    )),
              ],
            ),

          // Projects
          if (r.projects.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('PROJECTS'),
                ...r.projects.map((p) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text(p.title,
                                  style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: _darkGrey)),
                              pw.Text(' | ${p.tech}',
                                  style: pw.TextStyle(
                                      fontSize: 9, color: _midGrey)),
                            ],
                          ),
                          if (p.link != null)
                            pw.Text(p.link!,
                                style: pw.TextStyle(
                                    fontSize: 8.5, color: _green)),
                          pw.SizedBox(height: 3),
                          ...p.bullets.map(_bullet),
                        ],
                      ),
                    )),
              ],
            ),

          // Certifications
          if (r.certifications.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('CERTIFICATIONS'),
                pw.Wrap(
                    children: r.certifications.map(_chip).toList()),
                pw.SizedBox(height: 8),
              ],
            ),

          // Keywords matched
          if (r.keywordsMatched.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 4),
                _sectionTitle('ATS KEYWORDS MATCHED', color: _midGrey),
                pw.Wrap(
                  children: r.keywordsMatched
                      .map((k) => pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            margin: const pw.EdgeInsets.only(
                                right: 4, bottom: 4),
                            decoration: pw.BoxDecoration(
                              color: _lightGrey,
                              borderRadius: pw.BorderRadius.circular(3),
                            ),
                            child: pw.Text(k,
                                style: pw.TextStyle(
                                    fontSize: 8, color: _midGrey)),
                          ))
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _contactChip(String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 12, bottom: 2),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 9, color: _midGrey)),
    );
  }

  // ─── Modern template ──────────────────────────────────────────────────────

  static Future<Uint8List> _buildModern(GeneratedResume r) async {
    final doc = pw.Document();
    final c = r.contact;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => [
          // Green header band
          pw.Container(
            width: double.infinity,
            color: _green,
            padding: const pw.EdgeInsets.fromLTRB(28, 24, 28, 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(c.name,
                    style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: _white)),
                pw.SizedBox(height: 6),
                pw.Wrap(
                  children: [
                    _modernContactChip(c.email),
                    _modernContactChip(c.phone),
                    _modernContactChip(c.location),
                    if (c.linkedin != null)
                      _modernContactChip(c.linkedin!),
                    if (c.github != null) _modernContactChip(c.github!),
                  ],
                ),
              ],
            ),
          ),

          // Body
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(28, 18, 28, 28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('SUMMARY'),
                pw.Text(r.summary,
                    style: pw.TextStyle(fontSize: 9.5, color: _midGrey,
                        lineSpacing: 1.5)),
                pw.SizedBox(height: 12),

                _sectionTitle('SKILLS'),
                pw.Wrap(
                    children: r.skills.technical.map(_chip).toList()),
                pw.SizedBox(height: 5),
                if (r.skills.soft.isNotEmpty)
                  pw.Wrap(
                      children: r.skills.soft.map(_chip).toList()),
                pw.SizedBox(height: 12),

                _sectionTitle('EDUCATION'),
                ...r.education.map((e) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                        mainAxisAlignment:
                            pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(e.degree,
                                  style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: _darkGrey)),
                              pw.Text(e.institution,
                                  style: pw.TextStyle(
                                      fontSize: 9, color: _midGrey)),
                            ],
                          ),
                          pw.Text('${e.year}${e.gpa != null ? ' | GPA: ${e.gpa}' : ''}',
                              style: pw.TextStyle(
                                  fontSize: 9, color: _green)),
                        ],
                      ),
                    )),
                pw.SizedBox(height: 12),

                if (r.experience.isNotEmpty) ...[
                  _sectionTitle('EXPERIENCE'),
                  ...r.experience.map((e) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 10),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              color: _greenLight,
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    '${e.title} — ${e.company}',
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        color: _green),
                                  ),
                                  pw.Text(e.duration,
                                      style: pw.TextStyle(
                                          fontSize: 9, color: _midGrey)),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            ...e.bullets.map(_bullet),
                          ],
                        ),
                      )),
                ],

                if (r.projects.isNotEmpty) ...[
                  _sectionTitle('PROJECTS'),
                  ...r.projects.map((p) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Text('${p.title} ',
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        color: _darkGrey)),
                                pw.Text('[${p.tech}]',
                                    style: pw.TextStyle(
                                        fontSize: 9, color: _midGrey)),
                              ],
                            ),
                            ...p.bullets.map(_bullet),
                          ],
                        ),
                      )),
                ],

                if (r.certifications.isNotEmpty) ...[
                  _sectionTitle('CERTIFICATIONS'),
                  pw.Wrap(
                      children: r.certifications.map(_chip).toList()),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _modernContactChip(String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 16, bottom: 3),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 9,
              color: const PdfColor.fromInt(0xFFCCE8D8))),
    );
  }
}
