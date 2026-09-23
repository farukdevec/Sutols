import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/language_controller.dart';

enum _TextEditingMenuAction {
  cut,
  copy,
  paste,
  selectAll,
}

void showSutolTextEditingContextMenu({
  required BuildContext context,
  required TextEditingController controller,
  required Offset globalPosition,
  FocusNode? focusNode,
  ValueChanged<String>? onChanged,
  bool readOnly = false,
}) {
  _showSutolTextEditingContextMenu(
    context: context,
    controller: controller,
    globalPosition: globalPosition,
    focusNode: focusNode,
    onChanged: onChanged,
    readOnly: readOnly,
  );
}

Future<void> _showSutolTextEditingContextMenu({
  required BuildContext context,
  required TextEditingController controller,
  required Offset globalPosition,
  FocusNode? focusNode,
  ValueChanged<String>? onChanged,
  required bool readOnly,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject();
  if (overlay is! RenderBox) return;

  final initialSelection = controller.selection.isValid
      ? controller.selection
      : TextSelection.collapsed(offset: controller.text.length);
  final hasSelection = !initialSelection.isCollapsed;
  final canPaste = !readOnly;

  final action = await showMenu<_TextEditingMenuAction>(
    context: context,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    position: RelativeRect.fromRect(
      Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 1, 1),
      Offset.zero & overlay.size,
    ),
    items: <PopupMenuEntry<_TextEditingMenuAction>>[
      PopupMenuItem<_TextEditingMenuAction>(
        value: hasSelection && !readOnly ? _TextEditingMenuAction.cut : null,
        enabled: hasSelection && !readOnly,
        child: _TextEditingContextMenuRow(
          icon: Icons.content_cut_rounded,
          label: tr('Kes', 'Cut'),
        ),
      ),
      PopupMenuItem<_TextEditingMenuAction>(
        value: hasSelection ? _TextEditingMenuAction.copy : null,
        enabled: hasSelection,
        child: _TextEditingContextMenuRow(
          icon: Icons.content_copy_rounded,
          label: tr('Kopyala', 'Copy'),
        ),
      ),
      PopupMenuItem<_TextEditingMenuAction>(
        value: canPaste ? _TextEditingMenuAction.paste : null,
        enabled: canPaste,
        child: _TextEditingContextMenuRow(
          icon: Icons.content_paste_rounded,
          label: tr('Yapıştır', 'Paste'),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<_TextEditingMenuAction>(
        value: controller.text.isNotEmpty
            ? _TextEditingMenuAction.selectAll
            : null,
        enabled: controller.text.isNotEmpty,
        child: _TextEditingContextMenuRow(
          icon: Icons.select_all_rounded,
          label: tr('Tümünü Seç', 'Select All'),
        ),
      ),
    ],
  );
  if (action == null || !context.mounted) return;

  switch (action) {
    case _TextEditingMenuAction.copy:
      await Clipboard.setData(
        ClipboardData(text: initialSelection.textInside(controller.text)),
      );
    case _TextEditingMenuAction.cut:
      await Clipboard.setData(
        ClipboardData(text: initialSelection.textInside(controller.text)),
      );
      _replaceSelection(controller, initialSelection, '');
      onChanged?.call(controller.text);
    case _TextEditingMenuAction.paste:
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text == null) return;
      _replaceSelection(
        controller,
        initialSelection,
        clipboardData!.text!,
      );
      onChanged?.call(controller.text);
    case _TextEditingMenuAction.selectAll:
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
  }
  focusNode?.requestFocus();
}

void _replaceSelection(
  TextEditingController controller,
  TextSelection selection,
  String replacement,
) {
  final currentText = controller.text;
  final start = selection.start.clamp(0, currentText.length);
  final end = selection.end.clamp(start, currentText.length);
  final nextText = currentText.replaceRange(start, end, replacement);
  controller.value = TextEditingValue(
    text: nextText,
    selection: TextSelection.collapsed(offset: start + replacement.length),
  );
}

class _TextEditingContextMenuRow extends StatelessWidget {
  const _TextEditingContextMenuRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 19),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}
