import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/presentation_auto_builder.dart';
import '../state/presentation_controller.dart';
import 'design/design_system.dart';
import 'html_presentation_editor_page.dart';

class SutolHomePage extends StatefulWidget {
  const SutolHomePage({super.key});

  @override
  State<SutolHomePage> createState() => _SutolHomePageState();
}

class _SutolHomePageState extends State<SutolHomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  late final AnimationController _loadingAnimController;

  @override
  void initState() {
    super.initState();
    _loadingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    _loadingAnimController.dispose();
    super.dispose();
  }

  Future<void> _generatePresentation() async {
    final title = _titleController.text.trim();
    final prompt = _promptController.text.trim();
    if (title.isEmpty && prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    // Simulate AI generation delay
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final drafts = [PresentationDraftPage(title: title, body: prompt)];
    final generatedPages = const PresentationAutoBuilder().buildPages(drafts);

    final controller = PresentationController();
    controller.replaceDeck(generatedPages);

    setState(() {
      _isGenerating = false;
    });

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HtmlPresentationEditorPage(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // Ambient Glow Background
          const Positioned.fill(
            child: _AmbientGlowBackground(),
          ),
          
          // Content
          Column(
            children: [
              // Navbar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32, vertical: AppSpacing.s24),
                child: Row(
                  children: [
                    Text(
                      'Sutol',
                      style: AppTypography.headline.copyWith(
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main centered card
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create Professional Presentations',
                            textAlign: TextAlign.center,
                            style: AppTypography.display.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          Text(
                            'Transform your ideas into stunning slides instantly.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLarge.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s48),
                          
                          // The Card
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 680),
                            child: AnimatedSwitcher(
                              duration: AppMotion.standard,
                              child: _isGenerating
                                  ? _LoadingState(animation: _loadingAnimController)
                                  : _InputCard(
                                      titleController: _titleController,
                                      promptController: _promptController,
                                      onGenerate: _generatePresentation,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
      onHover: (event) {
        setState(() {
          _mousePos = event.localPosition;
        });
      },
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

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.titleController,
    required this.promptController,
    required this.onGenerate,
  });

  final TextEditingController titleController;
  final TextEditingController promptController;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s32),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: titleController,
            style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Presentation Title',
              filled: true,
              fillColor: colors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          TextField(
            controller: promptController,
            maxLines: 5,
            minLines: 3,
            style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'What is this presentation about? Describe your topic, key points, and audience...',
              filled: true,
              fillColor: colors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Oluştur'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.animation});
  
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s48),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: animation.value * 2 * math.pi,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        colors.accent.withValues(alpha: 0.1),
                        colors.accent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surfaceElevated,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.s32),
          Text(
            'Slaytlar hazırlanıyor...',
            style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Yapay zeka içeriğinizi yapılandırıyor ve tasarlıyor',
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
