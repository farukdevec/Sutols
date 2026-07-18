import 'package:flutter/material.dart';

import '../state/presentation_controller.dart';
import 'html_presentation_editor_page.dart';
import 'widgets/editor_shell.dart';

class PresentationEditorPage extends StatefulWidget {
  const PresentationEditorPage({super.key});

  @override
  State<PresentationEditorPage> createState() => _PresentationEditorPageState();
}

class _PresentationEditorPageState extends State<PresentationEditorPage> {
  late final PresentationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PresentationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openHtmlEditor() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HtmlPresentationEditorPage(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PresentationEditorShell(
      controller: _controller,
      title: 'Metin Yerlesim Editoru',
      subtitle:
          'Burada sadece beyaz sayfalari olustur, yazilari ekle ve yerlerini ayarla.',
      stageTitle: 'Sayfa Duzeni',
      stageHint:
          'Bir ogeye tiklayip tasiyabilir, bos alanda surukleyerek coklu secim yapabilirsin.',
      primaryActionLabel: 'Sunumu Olustur',
      onPrimaryAction: _openHtmlEditor,
      stageBuilder: (context, controller) {
        return PresentationPageCanvas(
          key: ValueKey<String>(controller.selectedPage.id),
          page: controller.selectedPage,
          selectedTextBlockId: controller.selectedTextBlockId,
          selectedTextBlockIds: controller.selectedTextBlockIds,
          interactive: true,
          showHint: true,
          onSelectTextBlock: controller.selectTextBlock,
          onDragSelectedText: controller.moveSelectedText,
          onInlineTextChanged: controller.updateSelectedText,
          onResizeSelectedTextWidth: controller.resizeSelectedTextWidth,
          onMarqueeSelectionChanged: ({
            required textBlockIds,
            required componentBlockIds,
          }) =>
              controller.selectItems(
            textBlockIds: textBlockIds,
            componentBlockIds: componentBlockIds,
          ),
          onClearSelection: controller.clearSelection,
        );
      },
    );
  }
}
