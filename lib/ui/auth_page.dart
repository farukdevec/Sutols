import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'design/design_system.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
        await AuthService.instance.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (_nameController.text.trim().isNotEmpty) {
          await AuthService.instance.currentUser
              ?.updateDisplayName(_nameController.text.trim());
        }
      }
      if (mounted) Navigator.of(context).pop();
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
      await AuthService.instance.signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
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

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', height: 28),
              const SizedBox(width: 8),
              Text('Sutol',
                  style: AppTypography.titleLarge
                      .copyWith(color: colors.textPrimary)),
            ],
          ),
          const SizedBox(height: AppSpacing.s32),
          _buildToggle(colors),
          const SizedBox(height: AppSpacing.s24),
          if (!_isLogin) ...[
            TextField(
              controller: _nameController,
              style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
              decoration: const InputDecoration(hintText: 'Adınız'),
            ),
            const SizedBox(height: AppSpacing.s16),
          ],
          TextField(
            controller: _emailController,
            style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
            decoration: const InputDecoration(hintText: 'E-posta'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.s16),
          TextField(
            controller: _passwordController,
            style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
            decoration: const InputDecoration(hintText: 'Şifre'),
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.s24),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s16),
              child: Text(_error!,
                  style: AppTypography.bodyMedium
                      .copyWith(color: colors.danger)),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(child: Divider(color: colors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Text('veya',
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
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
              label: const Text('Google ile Devam Et'),
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
              onTap: () => setState(() => _isLogin = true),
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
              onTap: () => setState(() => _isLogin = false),
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
              colors.accent.withValues(alpha: 0.06),
              colors.surface,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
