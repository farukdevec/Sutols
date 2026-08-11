import 'package:flutter/material.dart';

import '../design/design_system.dart';

/// Uygulama geneli dialog gösterimi / yönlendirme için kullanılan
/// navigator anahtarı. Hizmet katmanından (AuthService) dialog açmak
/// için `MaterialApp`'e `navigatorKey` olarak verilir.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Kayıt öncesi Kullanım Şartları / Gizlilik Politikası onay dialogunu
/// gösterir. Kullanıcı "Devam Et" butonuna basana kadar dialog
/// kapatılamaz (barrier dismissible değil, geri tuşu engelli).
///
/// Onaylandığında `true` döner; gösterim mümkün olmazsa `false`.
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

  void _openRoute(BuildContext context, String route) {
    Navigator.of(context, rootNavigator: true).pushNamed(route);
  }

  Widget _inlineLink(BuildContext context, String text, String route) {
    return TextButton(
      onPressed: () => _openRoute(context, route),
      style: TextButton.styleFrom(
        foregroundColor: context.colors.primary,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(text),
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
                    const TextSpan(
                      text:
                          "Sutols'u kullanmaya başlamak için ",
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: _inlineLink(
                        context,
                        "Kullanım Şartları'nı",
                        '/sartlar',
                      ),
                    ),
                    const TextSpan(text: ' ve '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: _inlineLink(
                        context,
                        "Gizlilik Politikası'nı",
                        '/gizlilik',
                      ),
                    ),
                    const TextSpan(
                      text: ' kabul etmeniz gerekiyor.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              CheckboxListTile(
                value: _agreed,
                onChanged: (value) =>
                    setState(() => _agreed = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: colors.primary,
                title: Text(
                  "Kullanım Şartları'nı ve Gizlilik Politikası'nı "
                  'okudum, kabul ediyorum',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
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