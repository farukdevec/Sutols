import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? _verificationNotice;
  bool _isPasswordResetNotice = false;
  Offset _authMousePosition = Offset.zero;

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
      _verificationNotice = null;
      _isPasswordResetNotice = false;
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
            _error = tr('Şifreler eşleşmiyor.', 'Passwords do not match.');
          });
          return;
        }
        await AuthService.instance.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          termsAccepted: _termsAgreed,
          displayName: _nameController.text,
        );
        if (mounted) {
          setState(() {
            _isLogin = true;
            _verificationNotice = tr(
              'Doğrulama e-postasını gönderdik. Gelen kutunuzu kontrol edip ardından giriş yapın.',
              'We sent a verification email. Check your inbox, then sign in.',
            );
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
        return;
      }
      if (mounted) AppRoutes.handleAppBack(context);
    } on TermsConsentNotApprovedException {
      setState(() {
        _error = tr(
          'Kullanım Şartları onaylanmadan kayıt tamamlanamaz.',
          'Registration cannot be completed without agreeing to Terms of Service.',
        );
      });
    } on EmailNotVerifiedException {
      setState(() {
        _verificationNotice = tr(
          'E-posta adresiniz henüz doğrulanmadı. Yeni doğrulama e-postası gönderdik.',
          'Your email address is not verified yet. We sent a new verification email.',
        );
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _mapError(e.code);
      });
    } catch (e) {
      setState(() {
        _error = tr(
          'Bir hata oluştu. Lütfen tekrar deneyin.',
          'An error occurred. Please try again.',
        );
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    await _signInWithProvider(AuthService.instance.signInWithGoogle);
  }

  Future<void> _signInWithApple() async {
    await _signInWithProvider(AuthService.instance.signInWithApple);
  }

  Future<void> _openGmail() async {
    final opened = await launchUrl(
      Uri.parse('https://mail.google.com/'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      setState(() {
        _error = tr(
          'Gmail açılamadı. Gelen kutunuzu tarayıcıdan kontrol edin.',
          'Gmail could not be opened. Check your inbox in a browser.',
        );
      });
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = tr(
            'Şifre sıfırlamak için e-posta adresinizi girin.',
            'Enter your email address to reset your password.',
          ));
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await AuthService.instance.sendPasswordResetEmail(email);
      if (mounted) {
        setState(() {
          _isPasswordResetNotice = true;
          _verificationNotice = tr(
            'Şifre sıfırlama bağlantısını gönderdik. Gmail’i açıp bağlantıdan yeni şifrenizi belirleyin.',
            'We sent a password reset link. Open Gmail and choose your new password from the link.',
          );
        });
      }
    } on FirebaseAuthException {
      // Hesap varlığını ifşa etmemek için aynı genel mesaj gösterilir.
      if (mounted) {
        setState(() {
          _isPasswordResetNotice = true;
          _verificationNotice = tr(
            'Bu e-posta adresi için şifre sıfırlama bağlantısı gönderdik.',
            'We sent a password reset link for this email address.',
          );
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = tr(
              'E-posta gönderilemedi. Lütfen tekrar deneyin.',
              'The email could not be sent. Please try again.',
            ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithProvider(
    Future<UserCredential> Function({bool termsAccepted}) signIn,
  ) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await signIn(
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
        _error = tr(
          'Bir hata oluştu. Lütfen tekrar deneyin.',
          'An error occurred. Please try again.',
        );
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
        return tr('E-posta veya şifre hatalı.', 'Invalid email or password.');
      case 'wrong-password':
        return tr('Şifre hatalı.', 'Wrong password.');
      case 'email-already-in-use':
        return tr('Bu e-posta zaten kayıtlı.', 'This email is already in use.');
      case 'weak-password':
        return tr('Şifre en az 6 karakter olmalıdır.',
            'Password must be at least 6 characters.');
      case 'invalid-email':
        return tr('Geçersiz e-posta adresi.', 'Invalid email address.');
      case 'user-disabled':
        return tr('Bu hesap devre dışı bırakılmış.',
            'This account has been disabled.');
      case 'operation-not-allowed':
        return tr('Bu giriş yöntemi şu an aktif değil.',
            'This sign-in method is currently disabled.');
      case 'account-exists-with-different-credential':
        return tr(
          'Bu e-posta ile farklı bir giriş yöntemi kullanılmış.',
          'An account already exists with a different credential.',
        );
      case 'popup-closed-by-user':
        return tr('Giriş işlemi iptal edildi.', 'Sign in was cancelled.');
      default:
        return tr('Bir hata oluştu: $code', 'An error occurred: $code');
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
        body: MouseRegion(
          onHover: (event) =>
              setState(() => _authMousePosition = event.localPosition),
          child: Stack(
            children: [
            Positioned.fill(
              child: _AuthAtmosphere(mousePosition: _authMousePosition),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s24, 76, AppSpacing.s24, AppSpacing.s32),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showQuotes = constraints.maxWidth >= 960;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showQuotes)
                          const Expanded(child: _RotatingBrandStory(side: _StorySide.left)),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: AnimatedSwitcher(
                            duration: AppMotion.standard,
                            child: _buildAuthCard(colors),
                          ),
                        ),
                        if (showQuotes)
                          const Expanded(child: _RotatingBrandStory(side: _StorySide.right)),
                      ],
                    );
                  },
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: const [
          BoxShadow(color: Color(0x1A3730A3), blurRadius: 42, offset: Offset(0, 20)),
          BoxShadow(color: Color(0x0D0F172A), blurRadius: 10, offset: Offset(0, 4)),
        ],
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
              style:
                  AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                  hintText: tr('Şifre (tekrar)', 'Password (confirm)')),
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
          if (_verificationNotice != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s16),
              child: Text(
                _verificationNotice!,
                style: AppTypography.bodyMedium
                    .copyWith(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          if (_verificationNotice != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s16),
              child: OutlinedButton.icon(
                onPressed: _openGmail,
                icon: const Icon(Icons.mail_outline_rounded),
                label: Text(_isPasswordResetNotice
                    ? tr('Gmail’i aç ve şifreni yenile',
                        'Open Gmail and reset password')
                    : tr('Gmail’i aç ve doğrula', 'Open Gmail and verify')),
              ),
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
                  : Text(_isLogin
                      ? tr('Giriş Yap', 'Sign In')
                      : tr('Kayıt Ol', 'Sign Up')),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          if (_isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _sendPasswordReset,
                child: Text(tr('Şifremi unuttum', 'Forgot password?')),
              ),
            ),
          if (_isLogin) const SizedBox(height: AppSpacing.s8),
          if (_isLogin) ...[
            Row(
              children: [
                Expanded(child: Divider(color: colors.border)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
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
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                label: Text(tr('Google ile Devam Et', 'Continue with Google')),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithApple,
                icon: const Icon(Icons.apple, size: 22),
                label: Text(tr('Apple ile Devam Et', 'Continue with Apple')),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            const _SignInLegalNotice(),
          ],
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
                  tr('Giriş Yap', 'Sign In'),
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
                  tr('Kayıt Ol', 'Sign Up'),
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

class _SignInLegalNotice extends StatefulWidget {
  const _SignInLegalNotice();

  @override
  State<_SignInLegalNotice> createState() => _SignInLegalNoticeState();
}

class _SignInLegalNoticeState extends State<_SignInLegalNotice> {
  late final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer()
    ..onTap = () => _openRoute('/sartlar', '/en/terms');
  late final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () => _openRoute('/gizlilik', '/en/privacy');

  void _openRoute(String trRoute, String enRoute) {
    Navigator.of(context).pushNamed(
      LanguageController.instance.isEnglish ? enRoute : trRoute,
    );
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnglish = LanguageController.instance.isEnglish;
    final linkStyle = AppTypography.labelSmall.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
        children: isEnglish
            ? [
                const TextSpan(text: 'By signing in, you agree to our '),
                TextSpan(
                    text: 'Terms of Service',
                    recognizer: _termsRecognizer,
                    style: linkStyle),
                const TextSpan(text: ' and '),
                TextSpan(
                    text: 'Privacy Policy',
                    recognizer: _privacyRecognizer,
                    style: linkStyle),
                const TextSpan(text: '.'),
              ]
            : [
                const TextSpan(text: 'Sitemize giriş yaparak '),
                TextSpan(
                    text: 'Kullanım Şartları',
                    recognizer: _termsRecognizer,
                    style: linkStyle),
                const TextSpan(text: "'nı ve "),
                TextSpan(
                    text: 'Gizlilik Politikası',
                    recognizer: _privacyRecognizer,
                    style: linkStyle),
                const TextSpan(text: "'nı okumuş ve kabul etmiş olursunuz."),
              ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

enum _StorySide { left, right }

class _BrandMessage {
  const _BrandMessage({
    required this.kicker,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String kicker;
  final String title;
  final String description;
  final IconData icon;
}

class _RotatingBrandStory extends StatefulWidget {
  const _RotatingBrandStory({required this.side});

  final _StorySide side;

  @override
  State<_RotatingBrandStory> createState() => _RotatingBrandStoryState();
}

class _RotatingBrandStoryState extends State<_RotatingBrandStory> {
  static const _leftMessages = [
    _BrandMessage(
      kicker: 'SUNUM, YENİDEN DÜŞÜNÜLDÜ',
      title: 'Fikirlerinize\nderinlik katın.',
      description: 'Yapay zekâ ile düşünceden etkileyici 3B hikâyelere.',
      icon: Icons.auto_awesome_rounded,
    ),
    _BrandMessage(
      kicker: 'HİKÂYENİZ HAREKET ETSİN',
      title: 'Her slayt\nbir deneyim.',
      description: 'Güçlü anlatım, akıcı hareket ve kusursuz ritim tek yerde.',
      icon: Icons.motion_photos_on_rounded,
    ),
    _BrandMessage(
      kicker: 'YARATICILIK İÇİN ALAN',
      title: 'Düşünceyi\nsahneye taşıyın.',
      description: 'Sutols, karmaşık fikirleri iz bırakan sunumlara dönüştürür.',
      icon: Icons.bubble_chart_rounded,
    ),
  ];

  static const _rightMessages = [
    _BrandMessage(
      kicker: 'ÜÇ BOYUTLU ETKİ',
      title: 'Sunumun yeni\nboyutu burada.',
      description: 'İzleyicinizin yalnızca görmediği, keşfettiği anlatılar.',
      icon: Icons.view_in_ar_rounded,
    ),
    _BrandMessage(
      kicker: 'İNOVASYONLA ANLATIN',
      title: 'Sıradanlığa\nyer bırakmayın.',
      description: 'Yeni nesil araçlarla fikrinizin potansiyelini görünür kılın.',
      icon: Icons.blur_on_rounded,
    ),
    _BrandMessage(
      kicker: 'FİKİRDEN ETKİYE',
      title: 'Anlatımınız\nhatırlansın.',
      description: 'Sutols, her sunuma özgün bir görsel dil kazandırır.',
      icon: Icons.insights_rounded,
    ),
  ];

  Timer? _timer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => _messageIndex++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLeft = widget.side == _StorySide.left;
    final messages = isLeft ? _leftMessages : _rightMessages;
    final message = messages[_messageIndex % messages.length];
    final alignment = isLeft ? Alignment.centerLeft : Alignment.centerRight;
    final textAlign = isLeft ? TextAlign.left : TextAlign.right;

    return Padding(
      padding: EdgeInsets.only(right: isLeft ? 40 : 0, left: isLeft ? 0 : 40),
      child: Align(
        alignment: alignment,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 365, minHeight: 370),
          padding: const EdgeInsets.all(34),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: isLeft ? Alignment.topLeft : Alignment.topRight,
              end: isLeft ? Alignment.bottomRight : Alignment.bottomLeft,
              colors: const [Color(0xEFFFFFFF), Color(0xB8F8FAFC)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: .9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x123B82F6),
                blurRadius: 48,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: isLeft ? -8 : null,
                left: isLeft ? null : -8,
                bottom: -24,
                child: Text(
                  '0${(_messageIndex % messages.length) + 1}',
                  style: TextStyle(
                    fontSize: 132,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5).withValues(alpha: .055),
                  ),
                ),
              ),
              Align(
                alignment: isLeft ? Alignment.topLeft : Alignment.topRight,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 550),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, .08),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(_messageIndex),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      Icon(message.icon, color: const Color(0xFF4F46E5), size: 27),
                      const SizedBox(height: 56),
                      Text(
                        message.kicker,
                        textAlign: textAlign,
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        message.title,
                        textAlign: textAlign,
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 31,
                          height: 1.12,
                          color: const Color(0xFF172554),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message.description,
                        textAlign: textAlign,
                        style: AppTypography.bodyLarge.copyWith(
                          color: const Color(0xFF64748B),
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment:
                    isLeft ? Alignment.bottomLeft : Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    messages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: isLeft ? 7 : 0, left: isLeft ? 0 : 7),
                      height: 3,
                      width: index == _messageIndex % messages.length ? 28 : 8,
                      decoration: BoxDecoration(
                        color: index == _messageIndex % messages.length
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfessionalBrandStory extends StatelessWidget {
  const _ProfessionalBrandStory({required this.side});

  final _StorySide side;

  @override
  Widget build(BuildContext context) {
    final left = side == _StorySide.left;
    final title = left
        ? tr('Fikirlerinize derinlik katın.', 'Give your ideas depth.')
        : tr('Sunumun yeni boyutu burada.', 'The next dimension of presenting is here.');
    final detail = left
        ? tr('Yapay zekâ ile düşünceden etkileyici 3B hikâyelere.',
            'From a thought to compelling 3D stories with AI.')
        : tr('Sutols, anlatımı inovasyonla buluşturur.',
            'Sutols brings storytelling and innovation together.');
    final label = left ? 'SUTOLS / ANLATIM' : 'SUTOLS / BOYUT';

    return Padding(
      padding: EdgeInsets.only(right: left ? 56 : 0, left: left ? 0 : 56),
      child: Align(
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 290),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .58),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFCBD5E1).withValues(alpha: .72),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment:
                    left ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  Icon(
                    left ? Icons.auto_awesome_rounded : Icons.view_in_ar_rounded,
                    color: const Color(0xFF4F46E5),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF4F46E5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: const Color(0xFFCBD5E1).withValues(alpha: .7),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: left ? TextAlign.left : TextAlign.right,
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 25,
                  height: 1.22,
                  color: const Color(0xFF172554),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                detail,
                textAlign: left ? TextAlign.left : TextAlign.right,
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandStory extends StatelessWidget {
  const _BrandStory({required this.side});

  final _StorySide side;

  @override
  Widget build(BuildContext context) {
    final left = side == _StorySide.left;
    final primary = left
        ? tr('Fikirlerinize derinlik katın.', 'Give your ideas depth.')
        : tr('Sunumun yeni boyutu burada.', 'The next dimension of presenting is here.');
    final secondary = left
        ? tr('Yapay zekâ ile düşünceden etkileyici 3B hikâyelere.', 'From a thought to compelling 3D stories with AI.')
        : tr('Sutols, anlatımı inovasyonla buluşturur.', 'Sutols brings storytelling and innovation together.');
    return Padding(
      padding: EdgeInsets.only(right: left ? 56 : 0, left: left ? 0 : 56),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Icon(left ? Icons.auto_awesome_rounded : Icons.view_in_ar_rounded,
              color: const Color(0xFF6366F1), size: 28),
          const SizedBox(height: 16),
          Text(primary,
              textAlign: left ? TextAlign.left : TextAlign.right,
              style: AppTypography.titleLarge.copyWith(
                fontSize: 27, height: 1.2, color: const Color(0xFF172554),
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 10),
          Text(secondary,
              textAlign: left ? TextAlign.left : TextAlign.right,
              style: AppTypography.bodyLarge.copyWith(color: const Color(0xFF64748B))),
          const SizedBox(height: 22),
          Text(left ? 'AI · 3D · MOTION' : 'SUTOLS · CREATE · IMPACT',
              style: AppTypography.labelSmall.copyWith(
                color: const Color(0xFF4F46E5), fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

class _AuthAtmosphere extends StatefulWidget {
  const _AuthAtmosphere({required this.mousePosition});

  final Offset mousePosition;

  @override
  State<_AuthAtmosphere> createState() => _AuthAtmosphereState();
}

class _AuthAtmosphereState extends State<_AuthAtmosphere> {

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 50),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: FractionalOffset(
            widget.mousePosition.dx / MediaQuery.of(context).size.width,
            widget.mousePosition.dy / MediaQuery.of(context).size.height,
          ),
          radius: 0.8,
          colors: [
            const Color(0xFF0A7E82).withValues(alpha: 0.06),
            colors.surface,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
