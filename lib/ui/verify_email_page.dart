import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../state/language_controller.dart';
import 'design/design_system.dart';
import 'design/sutol_widgets.dart';

/// Firebase Auth'un özel e-posta eylem URL'si için doğrulama ekranı.
///
/// Firebase şablonundaki bağlantı bu rota ile açılır ve `oobCode`, Firebase
/// SDK üzerinden uygulanır. `continueUrl` kasıtlı olarak otomatik açılmaz;
/// e-posta içeriğinden gelen bir URL'ye yönlendirme açık-yönlendirme riskidir.
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  _VerificationState _state = _VerificationState.loading;
  String? _errorCode;

  bool get _isPasswordReset => Uri.base.path == AppRoutes.resetPassword;

  @override
  void initState() {
    super.initState();
    _applyVerificationCode();
  }

  Future<void> _applyVerificationCode() async {
    final parameters = Uri.base.queryParameters;
    final mode = parameters['mode'];
    final code = parameters['oobCode'];

    // Firebase'in varsayılan handler'ı işlemi tamamlayıp continue URL'e
    // döndüğünde kod tekrar uygulanmaz; başarı ekranı gösterilir.
    if ((_isPasswordReset && parameters['reset'] == '1') ||
        (!_isPasswordReset && parameters['verified'] == '1')) {
      _showSuccess();
      return;
    }

    if (mode != 'verifyEmail' || code == null || code.isEmpty) {
      if (mounted) {
        setState(() {
          _state = _VerificationState.invalidLink;
        });
      }
      return;
    }

    try {
      await FirebaseAuth.instance.applyActionCode(code);
      await FirebaseAuth.instance.currentUser?.reload();
      _showSuccess();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _state = _VerificationState.failure;
          _errorCode = error.code;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _state = _VerificationState.failure);
      }
    }
  }

  void _showSuccess() {
    if (!mounted) return;
    setState(() => _state = _VerificationState.success);
    unawaited(Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    }));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnglish = LanguageController.instance.isEnglish;
    final title = switch (_state) {
      _VerificationState.loading => _isPasswordReset
          ? (isEnglish
              ? 'Completing password reset'
              : 'Şifre sıfırlama tamamlanıyor')
          : (isEnglish
              ? 'Verifying your email'
              : 'E-posta adresiniz doğrulanıyor'),
      _VerificationState.success => _isPasswordReset
          ? (isEnglish ? 'Password updated' : 'Şifreniz güncellendi')
          : (isEnglish ? 'Email verified' : 'E-posta adresiniz doğrulandı'),
      _VerificationState.invalidLink => isEnglish
          ? 'Invalid verification link'
          : 'Geçersiz doğrulama bağlantısı',
      _VerificationState.failure => isEnglish
          ? 'Verification link is no longer valid'
          : 'Doğrulama bağlantısı artık geçerli değil',
    };
    final message = switch (_state) {
      _VerificationState.loading => _isPasswordReset
          ? (isEnglish
              ? 'Please wait while we return you to Sutols.'
              : 'Sizi Sutols’a yönlendirirken lütfen bekleyin.')
          : (isEnglish
              ? 'Please wait while we securely confirm your email address.'
              : 'E-posta adresiniz güvenle doğrulanırken lütfen bekleyin.'),
      _VerificationState.success => _isPasswordReset
          ? (isEnglish
              ? 'Your password was changed successfully. Redirecting you to sign in…'
              : 'Şifreniz başarıyla güncellendi. Giriş sayfasına yönlendiriliyorsunuz…')
          : (isEnglish
              ? 'Your account is ready. Redirecting you to sign in…'
              : 'Hesabınız kullanıma hazır. Giriş sayfasına yönlendiriliyorsunuz…'),
      _VerificationState.invalidLink => isEnglish
          ? 'Use the latest verification link sent to your email address.'
          : 'E-posta adresinize gönderilen en güncel doğrulama bağlantısını kullanın.',
      _VerificationState.failure => _failureMessage(isEnglish),
    };

    return Title(
      title: '$title – Sutols',
      color: colors.accent,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s32),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border:
                      Border.all(color: colors.border.withValues(alpha: 0.5)),
                  boxShadow: AppShadows.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SutolsBrandLockup(height: 42),
                    const SizedBox(height: AppSpacing.s32),
                    _statusIcon(colors),
                    const SizedBox(height: SutolSpacing.xl),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.titleMedium
                          .copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge
                          .copyWith(color: colors.textSecondary),
                    ),
                    if (_state != _VerificationState.loading) ...[
                      const SizedBox(height: AppSpacing.s24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil(
                                  AppRoutes.login, (_) => false),
                          child: Text(isEnglish ? 'Sign in' : 'Giriş yap'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamedAndRemoveUntil(
                                AppRoutes.home, (_) => false),
                        child: Text(
                            isEnglish ? 'Go to home page' : 'Ana sayfaya dön'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(AppColors colors) {
    return switch (_state) {
      _VerificationState.loading => const SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      _VerificationState.success => Icon(
          Icons.verified_rounded,
          color: colors.accent,
          size: 52,
        ),
      _VerificationState.invalidLink || _VerificationState.failure => Icon(
          Icons.error_outline_rounded,
          color: colors.danger,
          size: 52,
        ),
    };
  }

  String _failureMessage(bool isEnglish) {
    switch (_errorCode) {
      case 'expired-action-code':
        return isEnglish
            ? 'This link has expired. Sign in again to receive a new verification email.'
            : 'Bu bağlantının süresi dolmuş. Yeni doğrulama e-postası almak için tekrar giriş yapın.';
      case 'invalid-action-code':
        return isEnglish
            ? 'This link has already been used or is invalid. Request a new verification email.'
            : 'Bu bağlantı daha önce kullanılmış veya geçersiz. Yeni bir doğrulama e-postası isteyin.';
      case 'user-disabled':
        return isEnglish
            ? 'This account has been disabled.'
            : 'Bu hesap devre dışı bırakılmış.';
      default:
        return isEnglish
            ? 'We could not verify this email. Request a new verification email and try again.'
            : 'Bu e-posta doğrulanamadı. Yeni bir doğrulama e-postası isteyip tekrar deneyin.';
    }
  }
}

enum _VerificationState { loading, success, invalidLink, failure }
