import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/database/seed_data.dart';
import 'package:unibite/core/design_system/brand_artwork.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';

/// Progressive 2-step student registration form (Account → Campus) with inline
/// validation and animated password-strength meter.
class RegisterScreen extends ConsumerStatefulWidget {
  /// Creates a [RegisterScreen].
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController(
    text: SeedData.demoVerificationCode,
  );

  int _step = 0;
  String? _selectedUniversityId;
  String? _selectedCampusId;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  double _passwordStrength() {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    var score = 0.0;
    if (p.length >= 6) score += 0.35;
    if (p.length >= 10) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[0-9]').hasMatch(p)) {
      score += 0.25;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  Future<void> _submit() async {
    if (_step == 0) {
      if (!_formKey.currentState!.validate()) return;
      setState(() {
        _step = 1;
        _errorMessage = null;
      });
      return;
    }

    if (_selectedUniversityId == null || _selectedCampusId == null) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .registerStudent(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
            verificationCode: _codeController.text,
          );
      await ref
          .read(authRepositoryProvider)
          .updateStudentCampus(
            userId: user.id,
            universityId: _selectedUniversityId!,
            campusId: _selectedCampusId!,
          );
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _step = 0;
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final strength = _passwordStrength();
    final strengthColor = strength < 0.4
        ? UniBiteColors.danger
        : (strength < 0.75 ? UniBiteColors.accent : UniBiteColors.primary500);
    final strengthLabel = strength < 0.4
        ? l10n.passwordStrengthWeak
        : (strength < 0.75
              ? l10n.passwordStrengthGood
              : l10n.passwordStrengthStrong);

    final universities =
        ref.watch(universitiesStreamProvider(true)).valueOrNull ?? [];
    final effectiveUniId =
        universities.any((u) => u.id == _selectedUniversityId)
        ? _selectedUniversityId
        : universities.firstOrNull?.id;
    final campuses = effectiveUniId == null
        ? const []
        : (ref
                  .watch(
                    campusesStreamProvider((
                      universityId: effectiveUniId,
                      activeOnly: true,
                    )),
                  )
                  .valueOrNull ??
              []);
    final effectiveCampusId = campuses.any((c) => c.id == _selectedCampusId)
        ? _selectedCampusId
        : campuses.firstOrNull?.id;
    _selectedUniversityId = effectiveUniId;
    _selectedCampusId = effectiveCampusId;

    return Scaffold(
      backgroundColor: UniBiteColors.primary900,
      appBar: AppBar(
        backgroundColor: UniBiteColors.primary900,
        foregroundColor: UniBiteColors.surface,
        title: Text(
          l10n.registerTitle,
          style: const TextStyle(color: UniBiteColors.surface),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 76,
            width: double.infinity,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: SwooshHeroPainter()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UniBiteTokens.screenPadding,
                  ),
                  child: Row(
                    children: [
                      _StepBadge(
                        label: l10n.stepAccount,
                        active: _step == 0,
                        done: _step > 0,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: UniBiteColors.primary500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StepBadge(
                        label: l10n.stepCampus,
                        active: _step == 1,
                        done: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: UniBiteColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(UniBiteTokens.r28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(UniBiteTokens.screenPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: UniBiteColors.dangerSoft,
                                borderRadius: BorderRadius.circular(
                                  UniBiteTokens.r12,
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: UniBiteColors.dangerText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: UniBiteTokens.s16),
                          ],
                          if (_step == 0) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: UniBiteColors.primary100,
                                borderRadius: BorderRadius.circular(
                                  UniBiteTokens.r12,
                                ),
                              ),
                              child: Text(
                                l10n.registerSubtitle,
                                style: const TextStyle(
                                  color: UniBiteColors.primary700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: UniBiteTokens.s16),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: l10n.fullNameLabel,
                                prefixIcon: const Icon(LucideIcons.user),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? l10n.fieldRequired
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: l10n.emailLabel,
                                hintText: l10n.emailHint,
                                prefixIcon: const Icon(LucideIcons.mail),
                              ),
                              validator: (v) {
                                final val = v?.trim() ?? '';
                                if (val.isEmpty) return l10n.fieldRequired;
                                if (!val.contains('@')) {
                                  return l10n.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: l10n.phoneOptionalLabel,
                                prefixIcon: const Icon(LucideIcons.phone),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: l10n.passwordLabel,
                                prefixIcon: const Icon(LucideIcons.lock),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return l10n.fieldRequired;
                                }
                                if (v.length < 6) return l10n.passwordTooShort;
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      UniBiteTokens.rPill,
                                    ),
                                    child: AnimatedContainer(
                                      duration: UniBiteTokens.normal,
                                      height: 6,
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      color: UniBiteColors.primary100,
                                      child: FractionallySizedBox(
                                        widthFactor: strength,
                                        child: Container(color: strengthColor),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  strengthLabel,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: strengthColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: l10n.confirmPasswordLabel,
                                prefixIcon: const Icon(LucideIcons.checkCheck),
                              ),
                              validator: (v) {
                                if (v != _passwordController.text) {
                                  return l10n.passwordsDoNotMatch;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.verificationCodeLabel,
                                prefixIcon: const Icon(LucideIcons.shieldCheck),
                                helperText: l10n.sendDemoCodeInfo,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? l10n.fieldRequired
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.registerTermsLine,
                              style: textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            UbPrimaryButton(
                              label: l10n.nextButton,
                              icon: LucideIcons.arrowRight,
                              onPressed: _submit,
                            ),
                          ] else ...[
                            Text(
                              l10n.selectUniversityLabel,
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: effectiveUniId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  LucideIcons.graduationCap,
                                ),
                              ),
                              items: universities
                                  .map(
                                    (u) => DropdownMenuItem<String>(
                                      value: u.id,
                                      child: Text(
                                        u.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() {
                                _selectedUniversityId = v;
                                _selectedCampusId = null;
                              }),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.selectCampusLabel,
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: campuses.map((c) {
                                final chosen = c.id == effectiveCampusId;
                                return ChoiceChip(
                                  selected: chosen,
                                  label: Text(
                                    c.name,
                                    style: TextStyle(
                                      color: chosen
                                          ? UniBiteColors.surface
                                          : UniBiteColors.ink,
                                    ),
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _selectedCampusId = c.id),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 22),
                            UbPrimaryButton(
                              label: l10n.registerButton,
                              icon: LucideIcons.checkCircle2,
                              isLoading: _isSubmitting,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: UbGhostButton(
                                label: l10n.cancel,
                                onPressed: () => setState(() => _step = 0),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Center(
                            child: UbGhostButton(
                              label: l10n.loginButton,
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.label,
    required this.active,
    required this.done,
  });

  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final bgColor = active
        ? AppColors.orange
        : (done ? AppColors.green500 : AppColors.green700);
    final fgColor = active ? AppColors.ink : AppColors.surface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: active ? AppShadow.soft : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fgColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
