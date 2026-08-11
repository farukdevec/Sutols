import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
      TapGestureRecognizer()..onTap = () => _openRoute('/sartlar');
  late final TapGestureRecognizer _privacyRecognizer =
      TapGestureRecognizer()..onTap = () => _openRoute('/gizlilik');

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
                      children: [
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
/// gösterir. Kullanıcı "Devam Et" butonuna basana kadar dialog
/// kapatılamaz (barrier dismissible değil, geri tuşu engelli).
///
/// Onaylandığında `true` döner; gösterim mümkün olmazsa `false`.
///
/// Not: kayıt formunda onay artık kutu (TermsConsentBox) ile satır içi
/// alındığı için bu dialog yalnızca "Giriş Yap" sekmesinden Google ile
/// ilk kez giriş yapan kullanıcılar için güvenlik ağı olarak kalır.
Future<bool> showTermsConsentDialog() async {
  final navigator = appNavigatorKey.currentState;
  if (navigator == null) return false;
  final result = await navigator.push<bool>(
    DialogRoute<bool>(
      context: navigator.context,
      barrierDismissible: false,
      barrierLabel: 'Kullanım Şartları onayı',
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
      TapGestureRecognizer()..onTap = () => _openRoute('/sartlar');
  late final TapGestureRecognizer _privacyRecognizer =
      TapGestureRecognizer()..onTap = () => _openRoute('/gizlilik');

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
          'Devam etmeden önce',
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
                  children: [
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
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }
}