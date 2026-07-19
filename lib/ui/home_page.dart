import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../services/presentation_auto_builder.dart';
import '../state/presentation_controller.dart';
import 'widgets/ai_load_animation.dart';
import 'design/design_system.dart';
import 'html_presentation_editor_page.dart';

class SutolHomePage extends StatefulWidget {
  const SutolHomePage({super.key});

  @override
  State<SutolHomePage> createState() => _SutolHomePageState();
}

class _SutolHomePageState extends State<SutolHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  String _loadingStepTitle = '';
  String _loadingStepDescription = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generatePresentation() async {
    final title = _titleController.text.trim();
    final prompt = _promptController.text.trim();
    if (title.isEmpty && prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _loadingStepTitle = 'Konu Araştırılıyor...';
      _loadingStepDescription = 'Yapay zeka internet üzerinde konunuzla ilgili en güncel bilgileri tarıyor.';
    });

    try {
      final aiService = AiService();
      final research = await aiService.research(prompt, maxResults: 3);

      if (!mounted) return;
      setState(() {
        _loadingStepTitle = 'İçerik Oluşturuluyor...';
        _loadingStepDescription = 'Araştırma sonuçları analiz ediliyor ve slayt metinleri yazılıyor.';
      });

      final slides = await aiService.generateSlides(prompt, slideCount: 5);

      if (!mounted) return;
      setState(() {
        _loadingStepTitle = 'Tasarım Hazırlanıyor...';
        _loadingStepDescription = 'Slaytlar için en uygun şablonlar, renkler ve yerleşimler seçiliyor.';
      });

      final drafts = slides
          .map((s) => PresentationDraftPage(title: s.title, body: s.body))
          .toList();

      if (research.summary.isNotEmpty) {
        drafts.insert(
          0,
          PresentationDraftPage(
            title: 'Arastirma Ozeti',
            body: research.summary,
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 800));
      final generatedPages = const PresentationAutoBuilder().buildPages(drafts);

      if (!mounted) return;
      setState(() {
        _loadingStepTitle = 'Son Rötuşlar Yapılıyor...';
        _loadingStepDescription = 'Sunum bileşenleri birleştiriliyor ve sahne hazırlanıyor.';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      final controller = PresentationController();
      controller.replaceDeck(generatedPages);

      setState(() {
        _isGenerating = false;
      });

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HtmlPresentationEditorPage(controller: controller),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/logo.png', height: 32),
                        const SizedBox(width: 10),
                        Text(
                          'Sutol',
                          style: AppTypography.headline.copyWith(
                            color: colors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _UserAvatar(),
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
                            'Fikirden sunuma, tek cümlede.',
                            textAlign: TextAlign.center,
                            style: AppTypography.display.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          Text(
                            'Anlatmak istediğinizi yazın. Sutol, sizin için tasarlanmış bir sunumu saniyeler içinde hazırlasın.',
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
                                  ? _LoadingState(
                                      title: _loadingStepTitle,
                                      description: _loadingStepDescription,
                                    )
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
              hintText: 'Sunum Başlığı',
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
              hintText: 'Bu sunum ne hakkında? Konuyu, ana fikirleri ve kitleyi kısaca anlatın...',
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
  const _LoadingState({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

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
          const AiLoadAnimation(size: 80, style: AiLoadStyle.spinningLight, message: ''),
          const SizedBox(height: AppSpacing.s32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              title,
              key: ValueKey<String>('title_$title'),
              style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              description,
              key: ValueKey<String>('desc_$description'),
              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.person_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
