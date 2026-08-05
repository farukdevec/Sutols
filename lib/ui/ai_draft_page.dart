import 'package:flutter/material.dart';

import '../models/slide_model.dart';
import '../services/ai_service.dart';
import '../services/presentation_auto_builder.dart';
import '../state/presentation_controller.dart';
import 'html_presentation_editor_page.dart';
import 'widgets/ai_load_animation.dart';
import 'widgets/source_selector.dart';

class AiDraftPage extends StatefulWidget {
  const AiDraftPage({super.key});

  @override
  State<AiDraftPage> createState() => _AiDraftPageState();
}

class _AiDraftPageState extends State<AiDraftPage> {
  final _topicController = TextEditingController();
  final _slideCountController = TextEditingController(text: '5');
  final _aiService = AiService();

  bool _connecting = true;
  bool _connected = false;
  String? _error;
  bool _generating = false;
  List<AiSlideContent>? _generatedSlides;
  AiResearchResponse? _researchResponse;
  bool _showSourceSelector = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _slideCountController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    setState(() => _connecting = true);
    final ok = await _aiService.checkHealth();
    setState(() {
      _connecting = false;
      _connected = ok;
      if (!ok) {
        _error = 'AI sunucusuna baglanilamadi.\n'
            '1. Ollama\'yi baslatin (ollama serve)\n'
            '2. Python backend\'i calistirin (python backend/main.py)\n'
            '3. Modelin indirildiginden emin olun (ollama pull llama3.2)';
      } else {
        _error = null;
      }
    });
  }

  Future<void> _generate() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() => _error = 'Lutfen bir konu girin');
      return;
    }

    setState(() {
      _generating = true;
      _error = null;
      _generatedSlides = null;
      _researchResponse = null;
      _showSourceSelector = false;
    });

    try {
      final research = await _aiService.research(topic, maxResults: 5);

      setState(() {
        _generating = false;
        _researchResponse = research;
        _showSourceSelector = true;
      });
    } catch (e) {
      setState(() {
        _generating = false;
        _error = 'Hata: $e';
      });
    }
  }

  Future<void> _onSourceConfirmed(SourceSelectionResult result) async {
    final topic = _topicController.text.trim();
    final slideCount = int.tryParse(_slideCountController.text.trim()) ?? 5;

    setState(() {
      _generating = true;
      _showSourceSelector = false;
    });

    try {
      final slides = await _aiService.generateSlides(topic, slideCount: slideCount);

      final drafts = <PresentationDraftPage>[];

      // Research summary with source citations
      if (_researchResponse != null && _researchResponse!.summary.isNotEmpty) {
        final sourcesText = result.selectedResults
            .map((r) => '• ${r.title}: ${r.url}')
            .join('\n');

        drafts.add(PresentationDraftPage(
          title: 'Arastirma Ozeti',
          body: '${_researchResponse!.summary}\n\nKaynaklar:\n$sourcesText',
        ));
      }

      // Generated slides
      drafts.addAll(slides.map((s) => PresentationDraftPage(
        title: s.title,
        body: s.body,
      )));

      // Analysis slides
      if (result.includeAnalysis) {
        try {
          final analysis = await _aiService.analyze(topic);

          if (analysis.summary.isNotEmpty) {
            drafts.add(PresentationDraftPage(
              title: 'Stratejik Analiz',
              body: analysis.summary,
            ));
          }
          if (analysis.swot.isNotEmpty) {
            drafts.add(PresentationDraftPage(
              title: 'SWOT Analizi',
              body: analysis.swot.map((i) => '${i.title}: ${i.content}').join('\n\n'),
            ));
          }
          if (analysis.keyStatistics.isNotEmpty) {
            drafts.add(PresentationDraftPage(
              title: 'Önemli İstatistikler',
              body: analysis.keyStatistics.map((i) => '${i.title}: ${i.content}').join('\n\n'),
            ));
          }
          if (analysis.trends.isNotEmpty) {
            drafts.add(PresentationDraftPage(
              title: 'Güncel Trendler',
              body: analysis.trends.map((i) => '${i.title}: ${i.content}').join('\n\n'),
            ));
          }
          if (analysis.recommendations.isNotEmpty) {
            drafts.add(PresentationDraftPage(
              title: 'Öneriler',
              body: analysis.recommendations.map((i) => '${i.title}: ${i.content}').join('\n\n'),
            ));
          }
        } catch (_) {}
      }

      setState(() {
        _generating = false;
        _generatedSlides = slides;
      });

      // Auto-apply to editor with analysis slides
      final builder = const PresentationAutoBuilder();
      final pages = builder.buildPages(drafts);

      final effectSettings = PresentationEffectSettings(
        transitionKind: PresentationTransitionKind.slide,
      );

      final controller = PresentationController();
      controller.replaceDeck(pages, effectSettings: effectSettings);

      if (!mounted) return;
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => HtmlPresentationEditorPage(controller: controller),
        ),
      );
    } catch (e) {
      setState(() {
        _generating = false;
        _error = 'Hata: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI ile Slayt Oluştur'),
        actions: [
          if (_connected)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('Bagli', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Baglantiyi kontrol et',
            onPressed: _checkConnection,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_connecting) {
      return const Center(
        key: ValueKey('connecting'),
        child: AiLoadAnimation(
          message: 'AI sunucusuna bağlanılıyor...',
          size: 80,
          style: AiLoadStyle.dots,
        ),
      );
    }

    if (!_connected) {
      return _ConnectionError(message: _error!, onRetry: _checkConnection);
    }

    if (_generating) {
      return const Center(
        key: ValueKey('generating'),
        child: AiLoadAnimation(
          message: 'Konu araştırılıyor ve slaytlar oluşturuluyor...',
          style: AiLoadStyle.dots,
        ),
      );
    }

    if (_showSourceSelector && _researchResponse != null) {
      return Padding(
        key: const ValueKey('source_selector'),
        padding: const EdgeInsets.all(24),
        child: SourceSelector(
          results: _researchResponse!.results,
          topic: _topicController.text.trim(),
          onConfirm: _onSourceConfirmed,
        ),
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('content'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputSection(theme),
          if (_researchResponse != null) ...[
            const SizedBox(height: 24),
            _buildResearchSection(theme),
          ],
          if (_generatedSlides != null) ...[
            const SizedBox(height: 24),
            _buildSlidesPreview(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sunum Konusu', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                hintText: 'Orn: Yapay Zeka, Iklim Degisikligi, Uzay Kesifleri...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.topic),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _slideCountController,
                    decoration: const InputDecoration(
                      labelText: 'Slayt Sayisi',
                      border: OutlineInputBorder(),
                      suffixText: 'adet',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _generating ? null : _generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('AI ile Oluştur'),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResearchSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Konu Araştırması', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(_researchResponse!.summary),
            if (_researchResponse!.results.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('Kaynaklar', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ..._researchResponse!.results.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(r.snippet,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(r.url,
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  void _applyToEditorFromPreview() {
    if (_generatedSlides == null || _generatedSlides!.isEmpty) return;
    final drafts = _generatedSlides!.map((s) => PresentationDraftPage(
      title: s.title,
      body: s.body,
    )).toList();
    final pages = const PresentationAutoBuilder().buildPages(drafts);
    final controller = PresentationController();
    controller.replaceDeck(pages, effectSettings: const PresentationEffectSettings(
      transitionKind: PresentationTransitionKind.slide,
    ));
    if (!mounted) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HtmlPresentationEditorPage(controller: controller),
      ),
    );
  }

  Widget _buildSlidesPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Oluşturulan Slaytlar', style: theme.textTheme.titleLarge),
            const Spacer(),
            FilledButton.icon(
              onPressed: _applyToEditorFromPreview,
              icon: const Icon(Icons.edit),
              label: const Text('Editöre Aktar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_generatedSlides!.length, (i) {
          final slide = _generatedSlides![i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text('${i + 1}',
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
              ),
              title: Text(slide.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                slide.body.length > 100
                    ? '${slide.body.substring(0, 100)}...'
                    : slide.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      Text(slide.body),
                      if (slide.speakerNotes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(),
                        Row(
                          children: [
                            Icon(Icons.mic, size: 16, color: theme.colorScheme.outline),
                            const SizedBox(width: 4),
                            Text('Sunucu Notu:', style: theme.textTheme.labelMedium),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(slide.speakerNotes,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ConnectionError extends StatelessWidget {
  const _ConnectionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'AI Sunucusuna Bağlanılamadı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yerel AI sunucusu çalışmıyor. Lütfen aşağıdaki adımları izleyin:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                message,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Geri Dön'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
