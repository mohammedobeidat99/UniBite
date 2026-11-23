import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/brand_artwork.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/unibite_logo.dart';

/// Custom campus-themed login screen with a deep-green floating swoosh hero
/// flowing into a `28px`-radius form sheet.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _heroFloatCtrl;

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  int _errorShakeSeed = 0;

  @override
  void initState() {
    super.initState();
    _heroFloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    if (!UniBiteTokens.isTestEnvironment) {
      _heroFloatCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _heroFloatCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorShakeSeed++);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .login(
            email: _emailController.text,
            password: _passwordController.text,
          );
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _errorShakeSeed++;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _fillDemoCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final heroHeight = keyboardOpen ? 132.0 : 244.0;

    return Scaffold(
      backgroundColor: UniBiteColors.primary900,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AnimatedContainer(
              duration: UniBiteTokens.normal,
              curve: UniBiteTokens.easeOut,
              height: heroHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: reduceMotion
                        ? const CustomPaint(painter: SwooshHeroPainter())
                        : RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _heroFloatCtrl,
                              builder: (_, _) => CustomPaint(
                                painter: SwooshHeroPainter(
                                  floatPhase: _heroFloatCtrl.value,
                                ),
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UniBiteTokens.screenPadding,
                      vertical: UniBiteTokens.s12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  AnimatedScale(
                                    scale: keyboardOpen ? 0.78 : 1.0,
                                    duration: UniBiteTokens.normal,
                                    child: const UniBiteLogo(size: 46),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      l10n.appTitle,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleLarge?.copyWith(
                                        color: UniBiteColors.surface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => ref
                                  .read(localeProvider.notifier)
                                  .toggleLocale(),
                              style: TextButton.styleFrom(
                                foregroundColor: UniBiteColors.surface,
                              ),
                              icon: const Icon(LucideIcons.languages, size: 18),
                              label: Text(
                                locale.languageCode == 'ar'
                                    ? l10n.englishLabel
                                    : l10n.arabicLabel,
                              ),
                            ),
                          ],
                        ),
                        if (!keyboardOpen) ...[
                          const Spacer(),
                          Text(
                            l10n.loginHeroHeadline,
                            style: textTheme.displaySmall?.copyWith(
                              color: UniBiteColors.surface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.loginHeroSubtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: UniBiteColors.primary100,
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
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
                  padding: const EdgeInsets.fromLTRB(
                    UniBiteTokens.screenPadding,
                    UniBiteTokens.s24,
                    UniBiteTokens.screenPadding,
                    UniBiteTokens.s24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.loginTitle,
                              style: textTheme.titleLarge?.copyWith(
                                color: UniBiteColors.primary700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.loginSubtitle,
                              style: textTheme.bodyMedium?.copyWith(
                                color: UniBiteColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: UniBiteTokens.s20),
                            if (_errorMessage != null) ...[
                              _ErrorBanner(
                                message: _errorMessage!,
                                shakeSeed: _errorShakeSeed,
                              ),
                              const SizedBox(height: UniBiteTokens.s16),
                            ],
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: l10n.emailLabel,
                                hintText: l10n.emailHint,
                                prefixIcon: const Icon(LucideIcons.mail),
                              ),
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) return l10n.fieldRequired;
                                if (!trimmed.contains('@')) {
                                  return l10n.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: UniBiteTokens.s16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: l10n.passwordLabel,
                                prefixIcon: const Icon(LucideIcons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                  icon: AnimatedSwitcher(
                                    duration: UniBiteTokens.fast,
                                    child: Icon(
                                      _obscurePassword
                                          ? LucideIcons.eye
                                          : LucideIcons.eyeOff,
                                      key: ValueKey(_obscurePassword),
                                    ),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.fieldRequired;
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: UbGhostButton(
                                label: l10n.forgotPasswordLink,
                                onPressed: () =>
                                    context.push('/reset-password'),
                              ),
                            ),
                            const SizedBox(height: UniBiteTokens.s8),
                            UbPrimaryButton(
                              label: l10n.loginButton,
                              icon: LucideIcons.logIn,
                              isLoading: _isSubmitting,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: UniBiteTokens.s8),
                            Center(
                              child: UbGhostButton(
                                label: l10n.registerStudentLink,
                                underlinedOrange: true,
                                onPressed: () => context.push('/register'),
                              ),
                            ),
                            const Divider(height: 28),
                            Text(
                              l10n.demoQuickFillTitle,
                              style: textTheme.labelMedium?.copyWith(
                                color: UniBiteColors.primary700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ActionChip(
                                  avatar: const Icon(
                                    LucideIcons.graduationCap,
                                    size: 16,
                                  ),
                                  label: Text(l10n.roleStudent),
                                  onPressed: () => _fillDemoCredentials(
                                    'student@just.edu.jo',
                                    'Student@123',
                                  ),
                                ),
                                ActionChip(
                                  avatar: const Icon(
                                    LucideIcons.store,
                                    size: 16,
                                  ),
                                  label: Text(l10n.roleCafeteriaAdmin),
                                  onPressed: () => _fillDemoCredentials(
                                    'admin.olive@just.edu.jo',
                                    'Cafe@123',
                                  ),
                                ),
                                ActionChip(
                                  avatar: const Icon(
                                    LucideIcons.chefHat,
                                    size: 16,
                                  ),
                                  label: Text(l10n.roleCafeteriaStaff),
                                  onPressed: () => _fillDemoCredentials(
                                    'staff.olive@just.edu.jo',
                                    'Staff@123',
                                  ),
                                ),
                                ActionChip(
                                  avatar: const Icon(
                                    LucideIcons.shieldCheck,
                                    size: 16,
                                  ),
                                  label: Text(l10n.roleSystemAdmin),
                                  onPressed: () => _fillDemoCredentials(
                                    'sysadmin@unibite.edu',
                                    'Admin@123',
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.shakeSeed});

  final String message;
  final int shakeSeed;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    final box = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UniBiteColors.dangerSoft,
        borderRadius: BorderRadius.circular(UniBiteTokens.r12),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            color: UniBiteColors.dangerText,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: UniBiteColors.dangerText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (reduceMotion) return box;
    return box
        .animate(key: ValueKey(shakeSeed))
        .shakeX(hz: 5, amount: 4, duration: UniBiteTokens.normal);
  }
}
