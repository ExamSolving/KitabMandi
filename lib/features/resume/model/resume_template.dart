import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/razorpay_config.dart';
import 'package:kitab_mandi/core/services/subscription_service.dart';

enum TemplateTier { free, plus, pro }

class ResumeTemplate {
  final String id;
  final String name;
  final String description;
  final TemplateTier tier;
  final Color primary;
  final Color accent;
  // 'single' | 'band' | 'sidebar' | 'timeline' | 'twocol'
  final String layout;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.primary,
    required this.accent,
    required this.layout,
  });

  String get tierLabel {
    switch (tier) {
      case TemplateTier.free:
        return 'Free';
      case TemplateTier.plus:
        return 'Plus';
      case TemplateTier.pro:
        return 'Pro';
    }
  }

  Color get tierColor {
    switch (tier) {
      case TemplateTier.free:
        return const Color(0xFF2E7D32);
      case TemplateTier.plus:
        return const Color(0xFF1565C0);
      case TemplateTier.pro:
        return const Color(0xFF6A1B9A);
    }
  }

  bool isUnlocked(Map<String, dynamic>? sub) {
    final plan = SubscriptionService.getPlan(sub);
    final active = SubscriptionService.isActive(sub);
    final isPro = active &&
        (plan == RazorpayConfig.planProMonthly ||
            plan == RazorpayConfig.planProAnnual);
    final isPlus = active &&
        (plan == RazorpayConfig.planPlusMonthly ||
            plan == RazorpayConfig.planPlusAnnual);
    switch (tier) {
      case TemplateTier.free:
        return true;
      case TemplateTier.plus:
        return isPlus || isPro;
      case TemplateTier.pro:
        return isPro;
    }
  }

  static const List<ResumeTemplate> all = [
    // ── FREE (1) ─────────────────────────────────────────────────────────────
    ResumeTemplate(
      id: 'classic',
      name: 'Classic',
      description: 'Clean & professional',
      tier: TemplateTier.free,
      primary: Color(0xFF1F5E3B),
      accent: Color(0xFFE8F5EE),
      layout: 'single',
    ),

    // ── PLUS (4 more = 5 total) ───────────────────────────────────────────────
    ResumeTemplate(
      id: 'modern',
      name: 'Modern',
      description: 'Coloured header band',
      tier: TemplateTier.plus,
      primary: Color(0xFF1F5E3B),
      accent: Color(0xFFE8F5EE),
      layout: 'band',
    ),
    ResumeTemplate(
      id: 'minimal',
      name: 'Minimal',
      description: 'Ultra-clean & simple',
      tier: TemplateTier.plus,
      primary: Color(0xFF1A1D23),
      accent: Color(0xFFF4F4F4),
      layout: 'single',
    ),
    ResumeTemplate(
      id: 'executive',
      name: 'Executive',
      description: 'Traditional & formal',
      tier: TemplateTier.plus,
      primary: Color(0xFF1A237E),
      accent: Color(0xFFE8EAF6),
      layout: 'single',
    ),
    ResumeTemplate(
      id: 'sidebar',
      name: 'Sidebar',
      description: 'Two-column layout',
      tier: TemplateTier.plus,
      primary: Color(0xFF1F5E3B),
      accent: Color(0xFFE8F5EE),
      layout: 'sidebar',
    ),

    // ── PRO (15 more = 20 total) ──────────────────────────────────────────────
    ResumeTemplate(
      id: 'bold',
      name: 'Bold',
      description: 'Strong typography',
      tier: TemplateTier.pro,
      primary: Color(0xFFBF360C),
      accent: Color(0xFFFBE9E7),
      layout: 'band',
    ),
    ResumeTemplate(
      id: 'elegant',
      name: 'Elegant',
      description: 'Refined & sophisticated',
      tier: TemplateTier.pro,
      primary: Color(0xFF795548),
      accent: Color(0xFFEFEBE9),
      layout: 'single',
    ),
    ResumeTemplate(
      id: 'navy',
      name: 'Navy',
      description: 'Deep blue header',
      tier: TemplateTier.pro,
      primary: Color(0xFF0D1B4B),
      accent: Color(0xFFE3F2FD),
      layout: 'band',
    ),
    ResumeTemplate(
      id: 'creative',
      name: 'Creative',
      description: 'Vibrant accent sidebar',
      tier: TemplateTier.pro,
      primary: Color(0xFF6A1B9A),
      accent: Color(0xFFF3E5F5),
      layout: 'sidebar',
    ),
    ResumeTemplate(
      id: 'tech',
      name: 'Tech Dark',
      description: 'Modern dark header',
      tier: TemplateTier.pro,
      primary: Color(0xFF1C2939),
      accent: Color(0xFFE3F2FD),
      layout: 'band',
    ),
    ResumeTemplate(
      id: 'timeline',
      name: 'Timeline',
      description: 'Visual timeline layout',
      tier: TemplateTier.pro,
      primary: Color(0xFF00695C),
      accent: Color(0xFFE0F2F1),
      layout: 'timeline',
    ),
    ResumeTemplate(
      id: 'compact',
      name: 'Compact',
      description: 'Dense two-column',
      tier: TemplateTier.pro,
      primary: Color(0xFF37474F),
      accent: Color(0xFFECEFF1),
      layout: 'twocol',
    ),
    ResumeTemplate(
      id: 'teal',
      name: 'Teal',
      description: 'Fresh teal accents',
      tier: TemplateTier.pro,
      primary: Color(0xFF006064),
      accent: Color(0xFFE0F7FA),
      layout: 'single',
    ),
    ResumeTemplate(
      id: 'crimson',
      name: 'Crimson',
      description: 'Bold red header',
      tier: TemplateTier.pro,
      primary: Color(0xFF8B0000),
      accent: Color(0xFFFFEBEE),
      layout: 'band',
    ),
    ResumeTemplate(
      id: 'forest',
      name: 'Forest',
      description: 'Deep green sidebar',
      tier: TemplateTier.pro,
      primary: Color(0xFF1B5E20),
      accent: Color(0xFFF1F8E9),
      layout: 'sidebar',
    ),
    ResumeTemplate(
      id: 'slate',
      name: 'Slate',
      description: 'Professional gray',
      tier: TemplateTier.pro,
      primary: Color(0xFF455A64),
      accent: Color(0xFFECEFF1),
      layout: 'single',
    ),
    ResumeTemplate(
      id: 'maroon',
      name: 'Maroon',
      description: 'Deep maroon accents',
      tier: TemplateTier.pro,
      primary: Color(0xFF6D1B1B),
      accent: Color(0xFFFCE4EC),
      layout: 'single',
    ),
    ResumeTemplate(
      id: 'portfolio',
      name: 'Portfolio',
      description: 'Projects-first layout',
      tier: TemplateTier.pro,
      primary: Color(0xFF283593),
      accent: Color(0xFFE8EAF6),
      layout: 'single',
    ),
    ResumeTemplate(
      id: 'gradient',
      name: 'Gradient',
      description: 'Vibrant gradient header',
      tier: TemplateTier.pro,
      primary: Color(0xFF6A1B9A),
      accent: Color(0xFFF3E5F5),
      layout: 'band',
    ),
    ResumeTemplate(
      id: 'gold',
      name: 'Gold',
      description: 'Premium gold accent',
      tier: TemplateTier.pro,
      primary: Color(0xFFB8860B),
      accent: Color(0xFFFFFDE7),
      layout: 'single',
    ),
  ];
}
