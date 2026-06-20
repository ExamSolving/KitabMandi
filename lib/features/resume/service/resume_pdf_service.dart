import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:kitab_mandi/features/resume/model/resume_model.dart';

class ResumePdfService {
  // ── Public entry points ───────────────────────────────────────────────────

  static Future<Uint8List> generate(ResumeRecord record) =>
      generateFrom(record.data, record.templateId);

  static Future<Uint8List> generateFrom(
      GeneratedResume r, String templateId) async {
    switch (templateId) {
      case 'modern':
        return _buildBand(r, _green, _green, _greenLight);
      case 'minimal':
        return _buildSingle(r, _darkGrey, _lightGrey, minimal: true);
      case 'executive':
        return _buildSingle(r, _navy, _navyLight);
      case 'sidebar':
        return _buildSidebar(r, _green, _green, _greenLight);
      case 'bold':
        return _buildBand(r, _red, _red, _redLight);
      case 'elegant':
        return _buildSingle(r, _brown, _brownLight);
      case 'navy':
        return _buildBand(r, _navy, _navy, _navyLight);
      case 'creative':
        return _buildSidebar(r, _purple, _purple, _purpleLight);
      case 'tech':
        return _buildBand(r, _techDark, _techDark, _techLight);
      case 'timeline':
        return _buildTimeline(r);
      case 'compact':
        return _buildTwoCol(r);
      case 'teal':
        return _buildSingle(r, _teal, _tealLight);
      case 'crimson':
        return _buildBand(r, _crimson, _crimson, _crimsonLight);
      case 'forest':
        return _buildSidebar(r, _forest, _forest, _forestLight);
      case 'slate':
        return _buildSingle(r, _slate, _slateLight);
      case 'maroon':
        return _buildSingle(r, _maroon, _maroonLight);
      case 'portfolio':
        return _buildSingle(r, _indigo, _indigoLight, portfolioFirst: true);
      case 'gradient':
        return _buildGradientBand(r);
      case 'gold':
        return _buildSingle(r, _gold, _goldLight);
      default: // classic
        return _buildSingle(r, _green, _greenLight);
    }
  }

  // Returns a dummy GeneratedResume for template preview
  static GeneratedResume sampleResume() {
    return GeneratedResume(
      contact: const ResumeContact(
        name: 'Aditya Kumar',
        email: 'aditya@email.com',
        phone: '+91 98765 43210',
        location: 'Bangalore, India',
        linkedin: 'linkedin.com/in/aditya',
        github: 'github.com/aditya',
      ),
      summary:
          'Results-driven software engineer with 3 years of experience building '
          'mobile and web applications. Passionate about clean code, '
          'performance, and exceptional user experiences.',
      skills: const ResumeSkills(
        technical: ['Flutter', 'Dart', 'Firebase', 'React', 'Node.js', 'SQL'],
        soft: ['Leadership', 'Communication', 'Problem Solving'],
      ),
      education: const [
        ResumeEduItem(
          degree: 'B.Tech Computer Science',
          institution: 'IIT Bombay',
          year: '2021',
          gpa: '8.5',
        ),
      ],
      experience: const [
        ResumeExpItem(
          title: 'Software Engineer',
          company: 'Tech Corp',
          duration: 'Jun 2021 – Present',
          bullets: [
            'Led development of a mobile app serving 100K+ users',
            'Reduced app load time by 40% through optimisations',
          ],
        ),
      ],
      projects: const [
        ResumeProjItem(
          title: 'KitabMandi',
          tech: 'Flutter, Firebase',
          link: 'github.com/aditya/kitabmandi',
          bullets: [
            'Built a book marketplace app with 10K+ downloads',
            'Integrated real-time chat and Razorpay payment gateway',
          ],
        ),
      ],
      certifications: ['AWS Cloud Practitioner', 'Google Flutter Developer'],
      keywordsMatched: [],
    );
  }

  // ── Palette ───────────────────────────────────────────────────────────────
  static const _green = PdfColor.fromInt(0xFF1F5E3B);
  static const _greenLight = PdfColor.fromInt(0xFFE8F5EE);
  static const _darkGrey = PdfColor.fromInt(0xFF1A1D23);
  static const _midGrey = PdfColor.fromInt(0xFF555A66);
  static const _lightGrey = PdfColor.fromInt(0xFFEEEEEE);
  static const _white = PdfColors.white;
  static const _navy = PdfColor.fromInt(0xFF1A237E);
  static const _navyLight = PdfColor.fromInt(0xFFE8EAF6);
  static const _red = PdfColor.fromInt(0xFFBF360C);
  static const _redLight = PdfColor.fromInt(0xFFFBE9E7);
  static const _brown = PdfColor.fromInt(0xFF795548);
  static const _brownLight = PdfColor.fromInt(0xFFEFEBE9);
  static const _purple = PdfColor.fromInt(0xFF6A1B9A);
  static const _purpleLight = PdfColor.fromInt(0xFFF3E5F5);
  static const _techDark = PdfColor.fromInt(0xFF1C2939);
  static const _techLight = PdfColor.fromInt(0xFFE3F2FD);
  static const _teal = PdfColor.fromInt(0xFF006064);
  static const _tealLight = PdfColor.fromInt(0xFFE0F7FA);
  static const _tealDot = PdfColor.fromInt(0xFF00695C);
  static const _crimson = PdfColor.fromInt(0xFF8B0000);
  static const _crimsonLight = PdfColor.fromInt(0xFFFFEBEE);
  static const _forest = PdfColor.fromInt(0xFF1B5E20);
  static const _forestLight = PdfColor.fromInt(0xFFF1F8E9);
  static const _slate = PdfColor.fromInt(0xFF455A64);
  static const _slateLight = PdfColor.fromInt(0xFFECEFF1);
  static const _maroon = PdfColor.fromInt(0xFF6D1B1B);
  static const _maroonLight = PdfColor.fromInt(0xFFFCE4EC);
  static const _indigo = PdfColor.fromInt(0xFF283593);
  static const _indigoLight = PdfColor.fromInt(0xFFE8EAF6);
  static const _gold = PdfColor.fromInt(0xFFB8860B);
  static const _goldLight = PdfColor.fromInt(0xFFFFFDE7);
  static const _gradPurple = PdfColor.fromInt(0xFF6A1B9A);
  static const _gradIndigo = PdfColor.fromInt(0xFF1A237E);

  // ── Generic helper widgets ────────────────────────────────────────────────

  static pw.Widget _sectionTitle(
    String text, {
    PdfColor color = _green,
    bool minimal = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: minimal ? _midGrey : color,
            letterSpacing: 1.1,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(height: minimal ? 0.5 : 1.5, color: minimal ? _lightGrey : color),
        pw.SizedBox(height: 6),
      ],
    );
  }

  static pw.Widget _bullet(String text, {PdfColor color = _green}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3, left: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '• ',
            style: pw.TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(fontSize: 9, color: _darkGrey, lineSpacing: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _chip(
    String text, {
    PdfColor bg = _greenLight,
    PdfColor textColor = _green,
    bool minimal = false,
  }) {
    if (minimal) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(right: 10, bottom: 2),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 8.5, color: _midGrey)),
      );
    }
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const pw.EdgeInsets.only(right: 5, bottom: 5),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          color: textColor,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _contactChip(String text, {PdfColor color = _midGrey}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 12, bottom: 2),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9, color: color)),
    );
  }

  static pw.Widget _eduRow(ResumeEduItem e, {PdfColor accent = _green}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                e.degree,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _darkGrey,
                ),
              ),
              pw.Text(e.institution,
                  style: pw.TextStyle(fontSize: 9.5, color: _midGrey)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(e.year, style: pw.TextStyle(fontSize: 9, color: _midGrey)),
              if (e.gpa != null)
                pw.Text('GPA: ${e.gpa}',
                    style: pw.TextStyle(fontSize: 9, color: accent)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _experienceSection(
    GeneratedResume r,
    PdfColor accent,
    bool minimal,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('EXPERIENCE', color: accent, minimal: minimal),
        ...r.experience.map(
          (e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      e.title,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _darkGrey,
                      ),
                    ),
                    pw.Text(e.duration,
                        style: pw.TextStyle(fontSize: 9, color: _midGrey)),
                  ],
                ),
                pw.Text(
                  e.company,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    color: accent,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 4),
                ...e.bullets.map((b) => _bullet(b, color: accent)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _projectsSection(
    GeneratedResume r,
    PdfColor accent,
    bool minimal,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('PROJECTS', color: accent, minimal: minimal),
        ...r.projects.map(
          (p) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      p.title,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _darkGrey,
                      ),
                    ),
                    pw.Text(' | ${p.tech}',
                        style: pw.TextStyle(fontSize: 9, color: _midGrey)),
                  ],
                ),
                if (p.link != null)
                  pw.Text(p.link!,
                      style: pw.TextStyle(fontSize: 8.5, color: accent)),
                pw.SizedBox(height: 3),
                ...p.bullets.map((b) => _bullet(b, color: accent)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── _buildSingle (10 templates) ───────────────────────────────────────────

  static Future<Uint8List> _buildSingle(
    GeneratedResume r,
    PdfColor accent,
    PdfColor accentBg, {
    bool portfolioFirst = false,
    bool minimal = false,
  }) async {
    final doc = pw.Document();
    final c = r.contact;

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
      build: (ctx) => [
        // Header
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              c.name,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: _darkGrey,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Wrap(children: [
              _contactChip(c.email),
              _contactChip(c.phone),
              _contactChip(c.location),
              if (c.linkedin != null) _contactChip(c.linkedin!),
              if (c.github != null) _contactChip(c.github!),
            ]),
            pw.SizedBox(height: 10),
            pw.Container(height: 2, color: accent),
            pw.SizedBox(height: 10),
          ],
        ),

        // Summary
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle('PROFESSIONAL SUMMARY', color: accent, minimal: minimal),
            pw.Text(
              r.summary,
              style: pw.TextStyle(fontSize: 9.5, color: _midGrey, lineSpacing: 1.5),
            ),
            pw.SizedBox(height: 12),
          ],
        ),

        // Skills
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle('SKILLS', color: accent, minimal: minimal),
            pw.Text(
              'Technical Skills',
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: _darkGrey,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Wrap(
              children: r.skills.technical
                  .map((s) => _chip(s, bg: accentBg, textColor: accent, minimal: minimal))
                  .toList(),
            ),
            if (r.skills.soft.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text(
                'Soft Skills',
                style: pw.TextStyle(
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _darkGrey,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Wrap(
                children: r.skills.soft
                    .map((s) => _chip(s, bg: accentBg, textColor: accent, minimal: minimal))
                    .toList(),
              ),
            ],
            pw.SizedBox(height: 12),
          ],
        ),

        // Education
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle('EDUCATION', color: accent, minimal: minimal),
            ...r.education.map((e) => _eduRow(e, accent: accent)),
            pw.SizedBox(height: 8),
          ],
        ),

        // Experience / Projects (portfolioFirst swaps the order)
        if (!portfolioFirst) ...[
          if (r.experience.isNotEmpty) _experienceSection(r, accent, minimal),
          if (r.projects.isNotEmpty) _projectsSection(r, accent, minimal),
        ] else ...[
          if (r.projects.isNotEmpty) _projectsSection(r, accent, minimal),
          if (r.experience.isNotEmpty) _experienceSection(r, accent, minimal),
        ],

        // Certifications
        if (r.certifications.isNotEmpty)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('CERTIFICATIONS', color: accent, minimal: minimal),
              pw.Wrap(
                children: r.certifications
                    .map((s) => _chip(s, bg: accentBg, textColor: accent, minimal: minimal))
                    .toList(),
              ),
              pw.SizedBox(height: 8),
            ],
          ),

        // ATS keywords
        if (r.keywordsMatched.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          _sectionTitle('ATS KEYWORDS MATCHED', color: _midGrey, minimal: minimal),
          pw.Wrap(
            children: r.keywordsMatched
                .map(
                  (k) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const pw.EdgeInsets.only(right: 4, bottom: 4),
                    decoration: pw.BoxDecoration(
                      color: _lightGrey,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(k,
                        style: pw.TextStyle(fontSize: 8, color: _midGrey)),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    ));

    return doc.save();
  }

  // ── _buildBand (5 templates) ──────────────────────────────────────────────

  static Future<Uint8List> _buildBand(
    GeneratedResume r,
    PdfColor headerBg,
    PdfColor accent,
    PdfColor accentBg,
  ) async {
    final doc = pw.Document();
    final c = r.contact;
    const lightContact = PdfColor(0.88, 0.88, 0.88);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        // Header band
        pw.Container(
          width: double.infinity,
          color: headerBg,
          padding: const pw.EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                c.name,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: _white,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Wrap(children: [
                _contactChip(c.email, color: lightContact),
                _contactChip(c.phone, color: lightContact),
                _contactChip(c.location, color: lightContact),
                if (c.linkedin != null) _contactChip(c.linkedin!, color: lightContact),
                if (c.github != null) _contactChip(c.github!, color: lightContact),
              ]),
            ],
          ),
        ),

        // Body
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 18, 28, 28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('SUMMARY', color: accent),
              pw.Text(r.summary,
                  style: pw.TextStyle(fontSize: 9.5, color: _midGrey, lineSpacing: 1.5)),
              pw.SizedBox(height: 12),

              _sectionTitle('SKILLS', color: accent),
              pw.Wrap(
                children: r.skills.technical
                    .map((s) => _chip(s, bg: accentBg, textColor: accent))
                    .toList(),
              ),
              if (r.skills.soft.isNotEmpty) ...[
                pw.SizedBox(height: 5),
                pw.Wrap(
                  children: r.skills.soft
                      .map((s) => _chip(s, bg: accentBg, textColor: accent))
                      .toList(),
                ),
              ],
              pw.SizedBox(height: 12),

              _sectionTitle('EDUCATION', color: accent),
              ...r.education.map((e) => _eduRow(e, accent: accent)),
              pw.SizedBox(height: 12),

              if (r.experience.isNotEmpty) ...[
                _sectionTitle('EXPERIENCE', color: accent),
                ...r.experience.map(
                  (e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          color: accentBg,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                '${e.title} — ${e.company}',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                              pw.Text(e.duration,
                                  style: pw.TextStyle(fontSize: 9, color: _midGrey)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        ...e.bullets.map((b) => _bullet(b, color: accent)),
                      ],
                    ),
                  ),
                ),
              ],

              if (r.projects.isNotEmpty) ...[
                _sectionTitle('PROJECTS', color: accent),
                ...r.projects.map(
                  (p) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(children: [
                          pw.Text('${p.title} ',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: _darkGrey,
                              )),
                          pw.Text('[${p.tech}]',
                              style: pw.TextStyle(fontSize: 9, color: _midGrey)),
                        ]),
                        ...p.bullets.map((b) => _bullet(b, color: accent)),
                      ],
                    ),
                  ),
                ),
              ],

              if (r.certifications.isNotEmpty) ...[
                _sectionTitle('CERTIFICATIONS', color: accent),
                pw.Wrap(
                  children: r.certifications
                      .map((s) => _chip(s, bg: accentBg, textColor: accent))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    ));

    return doc.save();
  }

  // ── _buildGradientBand (gradient template) ────────────────────────────────

  static Future<Uint8List> _buildGradientBand(GeneratedResume r) async {
    final doc = pw.Document();
    final c = r.contact;
    const lightContact = PdfColor(0.88, 0.88, 0.88);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.Container(
          width: double.infinity,
          decoration: const pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [_gradPurple, _gradIndigo],
              begin: pw.Alignment.centerLeft,
              end: pw.Alignment.centerRight,
            ),
          ),
          padding: const pw.EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(c.name,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold, color: _white)),
              pw.SizedBox(height: 6),
              pw.Wrap(children: [
                _contactChip(c.email, color: lightContact),
                _contactChip(c.phone, color: lightContact),
                _contactChip(c.location, color: lightContact),
                if (c.linkedin != null) _contactChip(c.linkedin!, color: lightContact),
                if (c.github != null) _contactChip(c.github!, color: lightContact),
              ]),
            ],
          ),
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 18, 28, 28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('SUMMARY', color: _gradPurple),
              pw.Text(r.summary,
                  style: pw.TextStyle(fontSize: 9.5, color: _midGrey, lineSpacing: 1.5)),
              pw.SizedBox(height: 12),

              _sectionTitle('SKILLS', color: _gradPurple),
              pw.Wrap(
                children: r.skills.technical
                    .map((s) => _chip(s, bg: _purpleLight, textColor: _gradPurple))
                    .toList(),
              ),
              if (r.skills.soft.isNotEmpty) ...[
                pw.SizedBox(height: 5),
                pw.Wrap(
                  children: r.skills.soft
                      .map((s) => _chip(s, bg: _purpleLight, textColor: _gradPurple))
                      .toList(),
                ),
              ],
              pw.SizedBox(height: 12),

              _sectionTitle('EDUCATION', color: _gradIndigo),
              ...r.education.map((e) => _eduRow(e, accent: _gradIndigo)),
              pw.SizedBox(height: 12),

              if (r.experience.isNotEmpty) ...[
                _sectionTitle('EXPERIENCE', color: _gradIndigo),
                ...r.experience.map(
                  (e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(e.title,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _darkGrey,
                                )),
                            pw.Text(e.duration,
                                style: pw.TextStyle(fontSize: 9, color: _midGrey)),
                          ],
                        ),
                        pw.Text(e.company,
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              color: _gradPurple,
                              fontStyle: pw.FontStyle.italic,
                            )),
                        pw.SizedBox(height: 4),
                        ...e.bullets.map((b) => _bullet(b, color: _gradPurple)),
                      ],
                    ),
                  ),
                ),
              ],

              if (r.projects.isNotEmpty) ...[
                _sectionTitle('PROJECTS', color: _gradIndigo),
                ...r.projects.map(
                  (p) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(children: [
                          pw.Text(p.title,
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: _darkGrey,
                              )),
                          pw.Text(' | ${p.tech}',
                              style: pw.TextStyle(fontSize: 9, color: _midGrey)),
                        ]),
                        if (p.link != null)
                          pw.Text(p.link!,
                              style: pw.TextStyle(fontSize: 8.5, color: _gradPurple)),
                        pw.SizedBox(height: 3),
                        ...p.bullets.map((b) => _bullet(b, color: _gradPurple)),
                      ],
                    ),
                  ),
                ),
              ],

              if (r.certifications.isNotEmpty) ...[
                _sectionTitle('CERTIFICATIONS', color: _gradIndigo),
                pw.Wrap(
                  children: r.certifications
                      .map((s) => _chip(s, bg: _purpleLight, textColor: _gradPurple))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    ));

    return doc.save();
  }

  // ── _buildSidebar (3 templates) ───────────────────────────────────────────

  static Future<Uint8List> _buildSidebar(
    GeneratedResume r,
    PdfColor sidebarBg,
    PdfColor accent,
    PdfColor accentBg,
  ) async {
    final doc = pw.Document();
    final c = r.contact;

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Sidebar ───────────────────────────────────────────────────
            pw.Container(
              width: 165,
              color: sidebarBg,
              padding: const pw.EdgeInsets.fromLTRB(16, 24, 14, 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    c.name,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _white,
                    ),
                  ),
                  pw.SizedBox(height: 14),

                  _sidebarHeading('CONTACT'),
                  _sidebarItem(c.email),
                  _sidebarItem(c.phone),
                  _sidebarItem(c.location),
                  if (c.linkedin != null) _sidebarItem(c.linkedin!),
                  if (c.github != null) _sidebarItem(c.github!),
                  pw.SizedBox(height: 14),

                  _sidebarHeading('SKILLS'),
                  ...r.skills.technical.map(_sidebarItem),
                  if (r.skills.soft.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    _sidebarHeading('SOFT SKILLS'),
                    ...r.skills.soft.map(_sidebarItem),
                  ],
                  pw.SizedBox(height: 14),

                  _sidebarHeading('EDUCATION'),
                  ...r.education.map(
                    (e) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            e.degree,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: _white,
                            ),
                          ),
                          pw.Text(
                            e.institution,
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColor(0.8, 0.8, 0.8),
                            ),
                          ),
                          pw.Text(
                            e.year,
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColor(0.7, 0.7, 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (r.certifications.isNotEmpty) ...[
                    pw.SizedBox(height: 14),
                    _sidebarHeading('CERTIFICATIONS'),
                    ...r.certifications.map(_sidebarItem),
                  ],
                ],
              ),
            ),

            // ── Main content ──────────────────────────────────────────────
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(22, 24, 28, 24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('PROFESSIONAL SUMMARY', color: accent),
                    pw.Text(
                      r.summary,
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        color: _midGrey,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.SizedBox(height: 14),

                    if (r.experience.isNotEmpty) ...[
                      _sectionTitle('EXPERIENCE', color: accent),
                      ...r.experience.map(
                        (e) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    e.title,
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: _darkGrey,
                                    ),
                                  ),
                                  pw.Text(e.duration,
                                      style: pw.TextStyle(
                                          fontSize: 9, color: _midGrey)),
                                ],
                              ),
                              pw.Text(
                                e.company,
                                style: pw.TextStyle(
                                  fontSize: 9.5,
                                  color: accent,
                                  fontStyle: pw.FontStyle.italic,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              ...e.bullets.map((b) => _bullet(b, color: accent)),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (r.projects.isNotEmpty) ...[
                      _sectionTitle('PROJECTS', color: accent),
                      ...r.projects.map(
                        (p) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(children: [
                                pw.Text(
                                  p.title,
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: _darkGrey,
                                  ),
                                ),
                                pw.Text(' | ${p.tech}',
                                    style: pw.TextStyle(
                                        fontSize: 9, color: _midGrey)),
                              ]),
                              if (p.link != null)
                                pw.Text(p.link!,
                                    style: pw.TextStyle(
                                        fontSize: 8.5, color: accent)),
                              pw.SizedBox(height: 3),
                              ...p.bullets.map((b) => _bullet(b, color: accent)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ));

    return doc.save();
  }

  static pw.Widget _sidebarHeading(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 7.5,
            fontWeight: pw.FontWeight.bold,
            color: const PdfColor(0.75, 0.9, 0.75),
            letterSpacing: 1.1,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(height: 0.5, color: const PdfColor(1, 1, 1, 0.25)),
        pw.SizedBox(height: 6),
      ],
    );
  }

  static pw.Widget _sidebarItem(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 4,
            height: 4,
            margin: const pw.EdgeInsets.only(top: 2.5, right: 6),
            decoration: const pw.BoxDecoration(
              color: PdfColors.white,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── _buildTimeline (1 template) ───────────────────────────────────────────

  static Future<Uint8List> _buildTimeline(GeneratedResume r) async {
    const accent = _tealDot;
    const accentBg = _tealLight;
    final doc = pw.Document();
    final c = r.contact;

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
      build: (ctx) => [
        // Header with accent underline
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              c.name,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: _darkGrey,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Container(width: 60, height: 3, color: accent),
            pw.SizedBox(height: 6),
            pw.Wrap(children: [
              _contactChip(c.email),
              _contactChip(c.phone),
              _contactChip(c.location),
              if (c.linkedin != null) _contactChip(c.linkedin!),
              if (c.github != null) _contactChip(c.github!),
            ]),
            pw.SizedBox(height: 14),
          ],
        ),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle('SUMMARY', color: accent),
            pw.Text(r.summary,
                style: pw.TextStyle(fontSize: 9.5, color: _midGrey, lineSpacing: 1.5)),
            pw.SizedBox(height: 12),
          ],
        ),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle('SKILLS', color: accent),
            pw.Wrap(
              children: r.skills.technical
                  .map((s) => _chip(s, bg: accentBg, textColor: accent))
                  .toList(),
            ),
            if (r.skills.soft.isNotEmpty) ...[
              pw.SizedBox(height: 5),
              pw.Wrap(
                children: r.skills.soft
                    .map((s) => _chip(s, bg: accentBg, textColor: accent))
                    .toList(),
              ),
            ],
            pw.SizedBox(height: 12),
          ],
        ),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle('EDUCATION', color: accent),
            ...r.education.map((e) => _eduRow(e, accent: accent)),
            pw.SizedBox(height: 8),
          ],
        ),

        // Experience with timeline dots
        if (r.experience.isNotEmpty)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('EXPERIENCE', color: accent),
              ...r.experience.map(
                (e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(children: [
                        pw.Container(
                          width: 10,
                          height: 10,
                          decoration: pw.BoxDecoration(
                            color: accent,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.Container(width: 2, height: 36, color: accentBg),
                      ]),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  e.title,
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: _darkGrey,
                                  ),
                                ),
                                pw.Text(e.duration,
                                    style: pw.TextStyle(fontSize: 9, color: _midGrey)),
                              ],
                            ),
                            pw.Text(
                              e.company,
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                color: accent,
                                fontStyle: pw.FontStyle.italic,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            ...e.bullets.map((b) => _bullet(b, color: accent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

        if (r.projects.isNotEmpty) _projectsSection(r, accent, false),

        if (r.certifications.isNotEmpty)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('CERTIFICATIONS', color: accent),
              pw.Wrap(
                children: r.certifications
                    .map((s) => _chip(s, bg: accentBg, textColor: accent))
                    .toList(),
              ),
            ],
          ),
      ],
    ));

    return doc.save();
  }

  // ── _buildTwoCol (1 template) ─────────────────────────────────────────────

  static Future<Uint8List> _buildTwoCol(GeneratedResume r) async {
    const accent = _slate;
    const accentBg = _slateLight;
    final doc = pw.Document();
    final c = r.contact;

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) {
        return pw.Column(
          children: [
            // Header bar
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.fromLTRB(24, 20, 24, 16),
              color: accent,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    c.name,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: _white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Wrap(children: [
                    _contactChip(c.email, color: const PdfColor(0.85, 0.85, 0.85)),
                    _contactChip(c.phone, color: const PdfColor(0.85, 0.85, 0.85)),
                    _contactChip(c.location,
                        color: const PdfColor(0.85, 0.85, 0.85)),
                    if (c.linkedin != null)
                      _contactChip(c.linkedin!,
                          color: const PdfColor(0.85, 0.85, 0.85)),
                    if (c.github != null)
                      _contactChip(c.github!,
                          color: const PdfColor(0.85, 0.85, 0.85)),
                  ]),
                ],
              ),
            ),

            // Two-column body
            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Left: education, skills, certs
                  pw.Container(
                    width: 175,
                    color: accentBg,
                    padding: const pw.EdgeInsets.fromLTRB(16, 18, 14, 18),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('EDUCATION', color: accent),
                        ...r.education.map(
                          (e) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(e.degree,
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: _darkGrey,
                                    )),
                                pw.Text(e.institution,
                                    style: pw.TextStyle(
                                        fontSize: 8.5, color: _midGrey)),
                                pw.Text(e.year,
                                    style: pw.TextStyle(
                                        fontSize: 8.5, color: _midGrey)),
                                if (e.gpa != null)
                                  pw.Text('GPA: ${e.gpa}',
                                      style: pw.TextStyle(
                                          fontSize: 8.5, color: accent)),
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 10),

                        _sectionTitle('SKILLS', color: accent),
                        ...r.skills.technical.map(
                          (s) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 3),
                            child: pw.Row(children: [
                              pw.Container(
                                width: 4,
                                height: 4,
                                decoration: const pw.BoxDecoration(
                                  color: accent,
                                  shape: pw.BoxShape.circle,
                                ),
                              ),
                              pw.SizedBox(width: 5),
                              pw.Text(s,
                                  style: pw.TextStyle(
                                      fontSize: 8.5, color: _darkGrey)),
                            ]),
                          ),
                        ),

                        if (r.skills.soft.isNotEmpty) ...[
                          pw.SizedBox(height: 10),
                          _sectionTitle('SOFT SKILLS', color: accent),
                          ...r.skills.soft.map(
                            (s) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: pw.Row(children: [
                                pw.Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const pw.BoxDecoration(
                                    color: accent,
                                    shape: pw.BoxShape.circle,
                                  ),
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(s,
                                    style: pw.TextStyle(
                                        fontSize: 8.5, color: _darkGrey)),
                              ]),
                            ),
                          ),
                        ],

                        if (r.certifications.isNotEmpty) ...[
                          pw.SizedBox(height: 10),
                          _sectionTitle('CERTIFICATIONS', color: accent),
                          ...r.certifications.map(
                            (s) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: pw.Text(s,
                                  style: pw.TextStyle(
                                      fontSize: 8.5, color: _darkGrey)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  pw.Container(width: 0.5, color: const PdfColor(0.8, 0.8, 0.8)),

                  // Right: summary, experience, projects
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(16, 18, 20, 18),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('SUMMARY', color: accent),
                          pw.Text(r.summary,
                              style: pw.TextStyle(
                                  fontSize: 9, color: _midGrey, lineSpacing: 1.5)),
                          pw.SizedBox(height: 12),

                          if (r.experience.isNotEmpty) ...[
                            _sectionTitle('EXPERIENCE', color: accent),
                            ...r.experience.map(
                              (e) => pw.Padding(
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
                                              fontSize: 9.5,
                                              fontWeight: pw.FontWeight.bold,
                                              color: _darkGrey,
                                            )),
                                        pw.Text(e.duration,
                                            style: pw.TextStyle(
                                                fontSize: 8.5, color: _midGrey)),
                                      ],
                                    ),
                                    pw.Text(e.company,
                                        style: pw.TextStyle(
                                          fontSize: 9,
                                          color: accent,
                                          fontStyle: pw.FontStyle.italic,
                                        )),
                                    pw.SizedBox(height: 3),
                                    ...e.bullets.map((b) => _bullet(b, color: accent)),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          if (r.projects.isNotEmpty) ...[
                            _sectionTitle('PROJECTS', color: accent),
                            ...r.projects.map(
                              (p) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 8),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(children: [
                                      pw.Text(p.title,
                                          style: pw.TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: pw.FontWeight.bold,
                                            color: _darkGrey,
                                          )),
                                      pw.Text(' | ${p.tech}',
                                          style: pw.TextStyle(
                                              fontSize: 8.5, color: _midGrey)),
                                    ]),
                                    if (p.link != null)
                                      pw.Text(p.link!,
                                          style: pw.TextStyle(
                                              fontSize: 8, color: accent)),
                                    ...p.bullets.map((b) => _bullet(b, color: accent)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ));

    return doc.save();
  }
}
