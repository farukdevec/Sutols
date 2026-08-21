import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../routes.dart';
import '../services/auth_service.dart';
import '../state/language_controller.dart';
import 'design/design_system.dart';
import 'design/sutol_widgets.dart';
import 'widgets/terms_consent_dialog.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _termsAgreed = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isLogin) {
        await AuthService.instance.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _error = 'Şifreler eşleşmiyor.';
          });
          return;
        }
        await AuthService.instance.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          termsAccepted: _termsAgreed,
        );
        if (_nameController.text.trim().isNotEmpty) {
          await AuthService.instance.currentUser
              ?.updateDisplayName(_nameController.text.trim());
        }
      }
      if (mounted) AppRoutes.handleAppBack(context);
    } on TermsConsentNotApprovedException {
      setState(() {
        _error = 'Kullanım Şartları onaylanmadan kayıt tamamlanamaz.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _mapError(e.code);
      });
    } catch (e) {
      setState(() {
        _error = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService.instance.signInWithGoogle(
        // "Kayıt Ol" sekmesindeyken onay formdaki kutucukla alındı;
        // "Giriş Yap" sekmesinden ilk kez giriş yapan yeni hesapta onay,
        // servis içindeki yedek dialog ile alınır.
        termsAccepted: !_isLogin && _termsAgreed,
      );
      if (mounted) AppRoutes.handleAppBack(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _mapError(e.code);
      });
    } catch (e) {
      setState(() {
        _error = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'wrong-password':
        return 'Şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kayıtlı.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi şu an aktif değil.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta ile farklı bir giriş yöntemi kullanılmış.';
      case 'popup-closed-by-user':
        return 'Giriş işlemi iptal edildi.';
      default:
        return 'Bir hata oluştu: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Title(
      title: _isLogin
          ? '${tr('Giriş Yap', 'Sign In')} – Sutols'
          : '${tr('Kayıt Ol', 'Sign Up')} – Sutols',
      color: colors.accent,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: BackButton(
            onPressed: () => AppRoutes.handleAppBack(context),
          ),
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: _AmbientGlowBackground()),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.s32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AnimatedSwitcher(
                    duration: AppMotion.standard,
                    child: _buildAuthCard(colors),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s32),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SutolsBrandLockup(height: 42),
          const SizedBox(height: AppSpacing.s32),
          _buildToggle(colors),
          const SizedBox(height: AppSpacing.s24),
          if (!_isLogin) ...[
            TextField(
              controller: _nameController,
              style:
                  AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(hintText: tr('Adınız', 'Your Name')),
            ),
            const SizedBox(height: AppSpacing.s16),
          ],
          TextField(
            controller: _emailController,
            style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(hintText: tr('E-posta', 'Email')),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.s16),
          if (!_isLogin) ...[
            TextField(
              controller: _confirmPasswordController,
              style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(hintText: tr('Şifre (tekrar)', 'Password (confirm)')),
            ),
            const SizedBox(height: AppSpacing.s16),
          ],
          TextField(
            controller: _passwordController,
            style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: tr('Şifre', 'Password'),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            obscureText: _obscurePassword,
          ),
          if (!_isLogin) ...[
            const SizedBox(height: AppSpacing.s16),
            TermsConsentBox(
              agreed: _termsAgreed,
              onChanged: (value) => setState(() => _termsAgreed = value),
            ),
          ],
          const SizedBox(height: AppSpacing.s24),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s16),
              child: Text(_error!,
                  style:
                      AppTypography.bodyMedium.copyWith(color: colors.danger)),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  _isLoading || (!_isLogin && !_termsAgreed) ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isLogin ? tr('Giriş Yap', 'Sign In') : tr('Kayıt Ol', 'Sign Up')),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(child: Divider(color: colors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Text(tr('veya', 'or'),
                    style: AppTypography.bodyMedium
                        .copyWith(color: colors.textSecondary)),
              ),
              Expanded(child: Divider(color: colors.border)),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading || (!_isLogin && !_termsAgreed)
                  ? null
                  : _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
              label: Text(tr('Google ile Devam Et', 'Continue with Google')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isLogin = true;
                  _termsAgreed = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: _isLogin ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md - 1),
                ),
                child: Text(
                  'Giriş Yap',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLarge.copyWith(
                    color: _isLogin ? colors.onPrimary : colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isLogin = false;
                  _termsAgreed = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: !_isLogin ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md - 1),
                ),
                child: Text(
                  'Kayıt Ol',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLarge.copyWith(
                    color: !_isLogin ? colors.onPrimary : colors.textSecondary,
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

class _AmbientGlowBackground extends StatefulWidget {
  const _AmbientGlowBackground();

  @override
  State<_AmbientGlowBackground> createState() => _AmbientGlowBackgroundState();
}

class _AmbientGlowBackgroundState extends State<_AmbientGlowBackground> {
  Offset _mousePos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MouseRegion(
      onHover: (event) => setState(() => _mousePos = event.localPosition),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: FractionalOffset(
              _mousePos.dx / MediaQuery.of(context).size.width,
              _mousePos.dy / MediaQuery.of(context).size.height,
            ),
            radius: 0.8,
            colors: [
              const Color(0xFF0A7E82).withValues(alpha: 0.06),
              colors.surface,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
