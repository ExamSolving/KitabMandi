import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/features/profile_edit/controller/profile_edit_controller.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class ProfileEditView extends StatelessWidget {
  ProfileEditView({super.key});

  final ctrl = Get.find<ProfileEditController>();
  final authCtrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA);
    final cardBg = isDark ? const Color(0xFF1A1D23) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: Form(
        key: ctrl.formKey,
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.primary,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              actions: [
                Obx(() => ctrl.isSaving.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ctrl.saveProfile();
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      )),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  // ── Avatar hero section ────────────────────────────────
                  _AvatarSection(ctrl: ctrl, authCtrl: authCtrl),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Personal info ──────────────────────────────
                        _SectionLabel(label: 'Personal Information'),
                        const SizedBox(height: 12),
                        _InfoCard(
                          isDark: isDark,
                          cardBg: cardBg,
                          theme: theme,
                          ctrl: ctrl,
                        ),

                        const SizedBox(height: 24),

                        // ── Account info (read-only) ───────────────────
                        _SectionLabel(label: 'Account'),
                        const SizedBox(height: 12),
                        _AccountCard(
                          isDark: isDark,
                          cardBg: cardBg,
                          theme: theme,
                          ctrl: ctrl,
                          authCtrl: authCtrl,
                        ),

                        const SizedBox(height: 32),

                        // ── Save button ────────────────────────────────
                        Obx(() => _SaveButton(
                              isSaving: ctrl.isSaving.value,
                              onTap: ctrl.saveProfile,
                            )),

                        const SizedBox(height: 20),

                        // ── Danger zone ────────────────────────────────
                        _DangerZone(isDark: isDark, authCtrl: authCtrl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar section ────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final ProfileEditController ctrl;
  final AuthController authCtrl;
  const _AvatarSection({required this.ctrl, required this.authCtrl});

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
      ),
      child: Obx(() {
        final data = authCtrl.userData.value;
        final name = data?['name'] as String? ?? 'User';
        final photoUrl = data?['photoUrl'] as String?;
        final localFile = ctrl.pickedImage.value;
        final initials = _initials(name);
        final isLoading = ctrl.isPickingImage.value;

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ctrl.showPhotoOptions(context);
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Avatar circle
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: isLoading
                          ? Container(
                              color: Colors.white.withValues(alpha: 0.2),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              ),
                            )
                          : localFile != null
                              ? Image.file(localFile, fit: BoxFit.cover)
                              : (photoUrl != null && photoUrl.isNotEmpty)
                                  ? Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _InitialsBg(initials: initials),
                                    )
                                  : _InitialsBg(initials: initials),
                    ),
                  ),
                  // Camera badge
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ctrl.showPhotoOptions(context);
              },
              child: Text(
                'Tap to change photo',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _InitialsBg extends StatelessWidget {
  final String initials;
  const _InitialsBg({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }
}

// ── Personal info card ────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final ThemeData theme;
  final ProfileEditController ctrl;

  const _InfoCard({
    required this.isDark,
    required this.cardBg,
    required this.theme,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        children: [
          // Name
          AppTextField(
            controller: ctrl.nameCtrl,
            label: 'Full Name',
            hintText: 'Enter your full name',
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.person_outline_rounded),
            validator: ctrl.validateName,
          ),
          const SizedBox(height: 14),
          // Phone
          AppTextField(
            controller: ctrl.phoneCtrl,
            label: 'Phone Number',
            hintText: 'Enter your 10-digit phone number',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.phone_outlined),
            validator: ctrl.validatePhone,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Account card (read-only) ──────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final ThemeData theme;
  final ProfileEditController ctrl;
  final AuthController authCtrl;

  const _AccountCard({
    required this.isDark,
    required this.cardBg,
    required this.theme,
    required this.ctrl,
    required this.authCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        children: [
          // Email read-only
          Padding(
            padding: const EdgeInsets.all(18),
            child: AppTextField(
              controller: ctrl.emailCtrl,
              label: 'Email Address',
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: const Icon(Icons.lock_outline_rounded),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.amber.withValues(alpha: 0.08)
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Email address cannot be changed for security reasons.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.amber.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Provider badge
          Obx(() {
            final provider =
                authCtrl.userData.value?['provider'] as String? ?? 'email';
            final isGoogle = provider == 'google';
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isGoogle
                              ? const Color(0xFF4285F4)
                              : AppColors.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isGoogle
                                ? const Color(0xFF4285F4)
                                : AppColors.primary)
                            .withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGoogle
                              ? Icons.g_mobiledata_rounded
                              : Icons.email_outlined,
                          size: 14,
                          color: isGoogle
                              ? const Color(0xFF4285F4)
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isGoogle
                              ? 'Signed in with Google'
                              : 'Signed in with Email',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isGoogle
                                ? const Color(0xFF4285F4)
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Save button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onTap;
  const _SaveButton({required this.isSaving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: isSaving
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: isSaving ? AppColors.primary.withValues(alpha: 0.5) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSaving
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  )
                ],
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Danger zone ───────────────────────────────────────────────────────────────

class _DangerZone extends StatelessWidget {
  final bool isDark;
  final AuthController authCtrl;
  const _DangerZone({required this.isDark, required this.authCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.red.withValues(alpha: 0.06)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.mediumImpact();
          _showDeleteDialog(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_forever_rounded,
                    size: 20, color: Colors.red),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Permanently remove your account and all data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: Colors.red.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor:
            isDark ? const Color(0xFF1A1D23) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded,
                    color: Colors.red, size: 30),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Delete Account?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Body
              Text(
                'All data associated with this account will be permanently deleted — listings, chats, resumes, and your profile. This cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons — equal width, single row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : Colors.black12,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.find<ProfileEditController>().deleteAccount();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Yes, Delete',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
