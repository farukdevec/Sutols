import 'package:flutter/material.dart';

import '../../../models/slide_model.dart';
import 'html_stage_document.dart';

class HtmlPageStage extends StatelessWidget {
  const HtmlPageStage({
    super.key,
    required this.page,
    this.selectedTextBlockId,
    this.selectedComponentBlockId,
    this.visibleRevealStep,
    this.showBadge = true,
    this.renderMode = HtmlStageRenderMode.full,
  });

  final PresentationPage page;
  final String? selectedTextBlockId;
  final String? selectedComponentBlockId;
  final int? visibleRevealStep;
  final bool showBadge;
  final HtmlStageRenderMode renderMode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFF7F9FD),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Text(
          'HTML sahnesi web uzerinde aktif olacak.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF142033),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
