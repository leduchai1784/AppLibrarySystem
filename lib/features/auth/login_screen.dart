import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.showWebStaffDeniedMessage = false,
    this.showAdminUseWebMessage = false,
  });

  /// Sau khi từ chối phiên web (sinh viên): hiện SnackBar giải thích.
  final bool showWebStaffDeniedMessage;

  /// Sau khi admin mở app mobile: nhắc đăng nhập trên web.
  final bool showAdminUseWebMessage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      if (widget.showWebStaffDeniedMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.loginSnackWebStaffOnly)),
        );
      }
      if (widget.showAdminUseWebMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.loginSnackAdminWebOnly)),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final t = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.enterEmailPassword)),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.verifyEmailBeforeLogin)),
          );
        }
        return;
      }

      if (!mounted) return;

      if (await AuthService.rejectWebSessionIfNotStaff()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.loginSnackWebStaffOnly)),
        );
        return;
      }

      if (await AuthService.rejectMobileSessionIfAdmin()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.loginSnackAdminWebOnly)),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = t.loginFailed;
      switch (e.code) {
        case 'user-not-found':
          message = t.authErrUserNotFound;
          break;
        case 'wrong-password':
          message = t.authErrWrongPassword;
          break;
        case 'invalid-email':
          message = t.invalidEmail;
          break;
        case 'invalid-credential':
          message = t.authErrInvalidCredential;
          break;
        case 'user-disabled':
          message = t.authErrUserDisabled;
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.genericErrorWithMessage('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  void _goToForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  Future<void> _onLoginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.signInWithGoogle();

      if (!mounted) return;

      if (await AuthService.rejectWebSessionIfNotStaff()) {
        if (!mounted) return;
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.loginSnackGoogleWebStaffOnly)),
        );
        return;
      }

      if (await AuthService.rejectMobileSessionIfAdmin()) {
        if (!mounted) return;
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.loginSnackAdminWebOnly)),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      String message = t.loginGoogleFailed;
      if (e.code == 'network-request-failed') {
        message = t.authErrNetwork;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.genericErrorWithMessage('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final inputTheme = InputDecorationTheme(
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.85), width: 1.5),
      ),
      hintStyle: TextStyle(fontSize: 14, color: theme.hintColor),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 12 + viewInsetsBottom,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Theme(
                data: theme.copyWith(inputDecorationTheme: inputTheme),
                child: _buildLoginCard(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_library_rounded,
            size: 28,
            color: theme.colorScheme.primary,
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.65),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 14,
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: theme.colorScheme.primary),
          Material(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _buildHeader(context)),
                  const SizedBox(height: 10),
                  Text(
                    t.loginTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kIsWeb ? t.loginSubtitleWeb : t.loginSubtitleMobile,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      height: 1.35,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: t.emailLabel,
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isLoading) _onLogin();
                    },
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: t.passwordLabel,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _goToForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        t.forgotPasswordTitle,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  t.loginTitle.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildOrDivider(context),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _onLoginWithGoogle,
                      icon: Icon(
                        Icons.g_mobiledata_rounded,
                        size: 22,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(t.signInWithGoogle, style: const TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),

                  if (!kIsWeb) ...[
                    const SizedBox(height: 12),
                    Center(child: _buildRegisterText(context)),
                  ],
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildOrDivider(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: theme.dividerColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          t.commonOr,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: theme.dividerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterText(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodySmall ?? AppTextStyles.caption;
    return RichText(
      text: TextSpan(
        text: '${t.noAccountPrefix} ',
        style: baseStyle,
        children: [
          TextSpan(
            text: t.registerAction,
            style: baseStyle.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()..onTap = _goToRegister,
          ),
        ],
      ),
    );
  }
}

