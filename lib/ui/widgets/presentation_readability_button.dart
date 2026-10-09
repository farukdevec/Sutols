import 'package:flutter/material.dart';
import '../../models/slide_model.dart';
import '../../services/presentation_readability_service.dart';
import '../../state/language_controller.dart';
import '../../state/presentation_controller.dart';
import 'editor_shell.dart';

class PresentationReadabilityButton extends StatelessWidget {
  const PresentationReadabilityButton({super.key, required this.controller});
  final PresentationController controller;

  String _description(ReadabilityIssueKind kind) => switch (kind) {
        ReadabilityIssueKind.lowContrast => tr(
            'Metin ile düz zemin arasındaki kontrast düşük. Daha belirgin bir metin rengi seçin.',
            'Low contrast between text and the flat background. Choose a clearer text color.'),
        ReadabilityIssueKind.longText => tr(
            'Metin uzun. Ayrı bir slayta bölmeyi düşünün.',
            'Long text. Consider splitting it across slides.'),
        ReadabilityIssueKind.smallFont => tr(
            'Yazı küçük. Sunumda okunması zor olabilir.',
            'Small type. It may be hard to read during a presentation.'),
        ReadabilityIssueKind.tightBox => tr(
            'Metin kutusu dar. Kutuyu büyütün veya metni başka bir slayta bölün.',
            'Tight text box. Enlarge it or split the text across slides.'),
        ReadabilityIssueKind.outsideStage => tr(
            'Metin kutusu sahne sınırını aşıyor. Konumunu veya boyutunu düzenleyin.',
            'Text box extends beyond the slide. Adjust its position or size.'),
      };

  void _inspect(BuildContext context) {
    final page = controller.selectedPage;
    final issues = PresentationReadabilityService.inspect(
      page: page,
      aspectRatio: controller.effectSettings.calculatedAspectRatio,
      styleFor: (b) => TextStyle(
          fontFamily: presentationFontFamily(b.textStyle),
          fontWeight: presentationFontWeight(b.effectiveFontWeight),
          fontStyle: b.textItalic ? FontStyle.italic : FontStyle.normal),
    );
    final blocks = {for (final b in page.textBlocks) b.id: b};
    showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(tr('Slayt okunurluğu', 'Slide readability')),
              content: SizedBox(
                  width: 480,
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr(
                          'Metin uzunluğu ve kutu ölçüleri için ön kontrol. Son görünümü sunum önizlemesinde kontrol edin.',
                          'Preflight of text length and box dimensions. Check the final appearance in presentation preview.')),
                      const SizedBox(height: 12),
                      if (issues.isEmpty)
                        Text(tr('Bu kontrolde uyarı bulunmadı.',
                            'No warnings in this check.')),
                      for (final issue in issues)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.info_outline_rounded),
                          title: Text(blocks[issue.blockId]!.text,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(_description(issue.kind)),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            if (controller.selectedPage.id == page.id)
                              controller.selectTextBlock(issue.blockId);
                          },
                        ),
                    ],
                  ))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(tr('Kapat', 'Close')))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        key: const ValueKey('readability-check-button'),
        onPressed: () => _inspect(context),
        icon: const Icon(Icons.fact_check_outlined),
        label: Text(tr('Okunurluğu kontrol et', 'Check readability')),
      );
}
