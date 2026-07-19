import 'dart:io';

void main() async {
  final file = File('lib/ui/html_presentation_editor_page.dart');
  String content = await file.readAsString();

  // Fix SutolColors invalid fields
  content = content.replaceAll('sutolColors.surfaceVariant', 'sutolColors.surfaceSubtle');
  content = content.replaceAll('sutolColors.surfaceTertiary', 'sutolColors.surfaceTinted');
  
  // Fix hardcoded hex colors to context colors
  content = content.replaceAll('const Color(0xFFF4F7FC)', 'context.sutolColors.surfaceSubtle');
  content = content.replaceAll('const Color(0xFFDCE5F1)', 'context.sutolColors.outline');
  content = content.replaceAll('const Color(0xFFF5F7FB)', 'context.sutolColors.surfaceSubtle');
  content = content.replaceAll('const Color(0xFFF0F5FF)', 'context.sutolColors.surfaceTinted');
  content = content.replaceAll('const Color(0xFFCBD6E6)', 'context.sutolColors.outline');
  
  // Dropdown background
  content = content.replaceAll('dropdownColor: Colors.white,', 'dropdownColor: context.sutolColors.surface,');

  // Colors.white replacements based on context
  // Replace Colors.white with context.sutolColors.surface where it implies a background
  content = content.replaceAll('color: Colors.white,', 'color: context.sutolColors.surface,');
  content = content.replaceAll('color: Colors.white.', 'color: context.sutolColors.surface.');
  
  // Fix the specific color in _FileMenuButton
  content = content.replaceAll(
    'final background = light ? Colors.white.withValues(alpha: 0.16) : context._htmlAccent;',
    'final background = context.sutolColors.surfaceSubtle;'
  );
  content = content.replaceAll(
    'final foreground = light ? Colors.white : Colors.white;',
    'final foreground = context._htmlInk;'
  );
  content = content.replaceAll(
    'final border = light ? Border.all(color: Colors.white.withValues(alpha: 0.16)) : null;',
    'final border = Border.all(color: context.sutolColors.outline);'
  );

  // Fix _HistoryButtons
  content = content.replaceAll(
    'final background = light ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFF4F7FC);',
    'final background = context.sutolColors.surfaceSubtle;'
  );
  content = content.replaceAll(
    'final borderColor = light ? Colors.white.withValues(alpha: 0.16) : const Color(0xFFDCE5F1);',
    'final borderColor = context.sutolColors.outline;'
  );
  content = content.replaceAll(
    'final enabledColor = light ? Colors.white : context._htmlInk;',
    'final enabledColor = context._htmlInk;'
  );
  content = content.replaceAll(
    'final disabledColor = light ? Colors.white.withValues(alpha: 0.42) : context._htmlMuted.withValues(alpha: 0.52);',
    'final disabledColor = context._htmlMuted.withValues(alpha: 0.52);'
  );

  // Fix header action text
  content = content.replaceAll('color: Colors.white', 'color: context.sutolColors.onPrimary');
  
  // Remove light parameter usage where it's no longer valid
  content = content.replaceAll('light: true,', '');
  content = content.replaceAll('light: false,', '');

  await file.writeAsString(content);
  print('Done replacing colors.');
}
