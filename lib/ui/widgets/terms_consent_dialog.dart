import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../state/language_controller.dart';
import '../design/design_system.dart';

/// Uygulama geneli dialog gösterimi / yönlendirme için kullanılan
/// navigator anahtarı. Hizmet katmanından (AuthService) dialog açmak
/// için `MaterialApp`'e `navigatorKey` olarak verilir.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Kayıt formunda ve onay dialogunda kullanılan tıklanabilir çerçeveli
/// onay kutucuğu. Kutucuğun herhangi bir yerine tıklayınca tik
/// işaretlenir/bozulur; "Kullanım Şartları" ve "Gizlilik Politikası"
/// linkleri aynı satırda (hizalı), kalın + altı çizili ve tıklanabilirdir.
class TermsConsentBox extends StatefulWidget {
  const TermsConsentBox({
    super.key,
    required this.agreed,
    required this.onChanged,
  });

  final bool agreed;
  final ValueChanged<bool> onChanged;

  @override
  State<TermsConsentBox> createState() => _TermsConsentBoxState();
}

class _TermsConsentBoxState extends State<TermsConsentBox> {
  late final TapGestureRecognizer _termsRecognizer =
      TapGestureRecognizer()..onTap = () {
        final route = LanguageController.instance.isEnglish ? '/en/terms' : '/sartlar';
        _openRoute(route);
      };
  late final TapGestureRecognizer _privacyRecognizer =
      TapGestureRecognizer()..onTap = () {
        final route = LanguageController.instance.isEnglish ? '/en/privacy' : '/gizlilik';
        _openRoute(route);
      };

  void _openRoute(String route) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamed(route);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  /// Aynı paragrafın içinde, metinle aynı hizada duran tıklanabilir link.
  TextSpan _linkSpan(
    String text,
    TapGestureRecognizer recognizer,
  ) {
    final primary = context.colors.primary;
    return TextSpan(
      text: text,
      recognizer: recognizer,
      style: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
        decorationColor: primary.withValues(alpha: 0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEn = LanguageController.instance.isEnglish;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onChanged(!widget.agreed),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: widget.agreed ? colors.primary : colors.border,
              width: widget.agreed ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: widget.agreed,
                onChanged: (value) => widget.onChanged(value ?? false),
                activeColor: colors.primary,
              ),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      children: isEn
                          ? [
                              const TextSpan(text: 'I have read and accept the '),
                              _linkSpan('Terms of Service', _termsRecognizer),
                              const TextSpan(text: ' and '),
                              _linkSpan('Privacy Policy', _privacyRecognizer),
                            ]
                          : [
                              _linkSpan('Kullanım Şartları', _termsRecognizer),
                              const TextSpan(text: "'nı ve "),
                              _linkSpan('Gizlilik Politikası', _privacyRecognizer),
                              const TextSpan(text: "'nı okudum, kabul ediyorum"),
                            ],
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

/// Kayıt öncesi Kullanım Şartları / Gizlilik Politikası onay dialogunu
/// gösterir.
Future<bool> showTermsConsentDialog() async {
  final navigator = appNavigatorKey.currentState;
  if (navigator == null) return false;
  final result = await navigator.push<bool>(
    DialogRoute<bool>(
      context: navigator.context,
      barrierDismissible: false,
      barrierLabel: tr('Kullanım Şartları onayı', 'Terms of Service consent'),
      builder: (_) => const TermsConsentDialog(),
    ),
  );
  return result ?? false;
}

class TermsConsentDialog extends StatefulWidget {
  const TermsConsentDialog({super.key});

  @override
  State<TermsConsentDialog> createState() => _TermsConsentDialogState();
}

class _TermsConsentDialogState extends State<TermsConsentDialog> {
  bool _agreed = false;

  late final TapGestureRecognizer _termsRecognizer =
      TapGestureRecognizer()..onTap = () {
        final route = LanguageController.instance.isEnglish ? '/en/terms' : '/sartlar';
        _openRoute(route);
      };
  late final TapGestureRecognizer _privacyRecognizer =
      TapGestureRecognizer()..onTap = () {
        final route = LanguageController.instance.isEnglish ? '/en/privacy' : '/gizlilik';
        _openRoute(route);
      };

  void _openRoute(String route) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamed(route);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  TextSpan _linkSpan(String text, TapGestureRecognizer recognizer) {
    final primary = context.colors.primary;
    return TextSpan(
      text: text,
      recognizer: recognizer,
      style: TextStyle(
        color: primary,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: primary.withValues(alpha: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEn = LanguageController.instance.isEnglish;

    return PopScope(
      // Kullanıcı geri tuşuyla / dışarı tıklayarak dialogu kapatamasın.
      canPop: false,
      child: AlertDialog(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          tr('Devam etmeden önce', 'Before you continue'),
          style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  children: isEn
                      ? [
                          const TextSpan(text: 'To start using Sutols, you must accept the '),
                          _linkSpan('Terms of Service', _termsRecognizer),
                          const TextSpan(text: ' and '),
                          _linkSpan('Privacy Policy', _privacyRecognizer),
                          const TextSpan(text: '.'),
                        ]
                      : [
                          const TextSpan(text: "Sutols'u kullanmaya başlamak için "),
                          _linkSpan("Kullanım Şartları'nı", _termsRecognizer),
                          const TextSpan(text: ' ve '),
                          _linkSpan("Gizlilik Politikası'nı", _privacyRecognizer),
                          const TextSpan(text: ' kabul etmeniz gerekiyor.'),
                        ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              TermsConsentBox(
                agreed: _agreed,
                onChanged: (value) => setState(() => _agreed = value),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            // Onay işaretlenmeden devam edilemez.
            onPressed: _agreed ? () => Navigator.of(context).pop(true) : null,
            child: Text(tr('Devam Et', 'Continue')),
          ),
        ],
      ),
    );
  }
}