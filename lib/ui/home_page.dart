import 'package:flutter/material.dart';

import '../state/presentation_controller.dart';
import 'presentation_text_draft_page.dart';

class SutolHomePage extends StatelessWidget {
  const SutolHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: context.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 64,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: SutolColors.brandGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(0, 8))],
                  ),
                  child: Text(
                    'NEW',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Create Professional',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: context.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.03,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Presentations',
                  style: theme.textTheme.displayLarge?.copyWith(
                    background: Paint()
                      ..shader = LinearGradient(
                        colors: [context.seed, context.seed.withValues(alpha: 0.6)],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 40)),
                    foregroundColor: Colors.transparent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.03,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Transform your ideas into stunning presentations with AI-powered tools. Create, edit, and present like the pros with our intuitive platform.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 56),
                Row(
                  children: <Widget>[
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: context.seed,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: SutolColors.shadow, blurRadius: 12, offset: Offset(0, 4))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const _ModernPresentationEntryPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  'Start Creating',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const _ModernPresentationEntryPage(),
                          ),
                        );
                      },
                      icon: Icon(Icons.play_circle_outline_rounded, color: context.seed, size: 24),
                      label: Text(
                        'Watch Demo',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: context.seed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                Row(
                  children: <Widget>[
                    _FeatureBadge(
                      icon: Icons.design_services_rounded,
                      text: 'Professional Templates',
                    ),
                    const SizedBox(width: 16),
                    _FeatureBadge(
                      icon: Icons.auto_awesome_rounded,
                      text: 'AI-Powered Generation',
                    ),
                    const SizedBox(width: 16),
                    _FeatureBadge(
                      icon: Icons.settings_suggest_rounded,
                      text: 'Customizable',
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernPresentationEntryPage extends StatefulWidget {
  const _ModernPresentationEntryPage();

  @override
  State<_ModernPresentationEntryPage> createState() => _ModernPresentationEntryPageState();
}

class _ModernPresentationEntryPageState extends State<_ModernPresentationEntryPage> {
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

  @override
  Widget build(BuildContext context) {
    return PresentationTextDraftPage(controller: _controller);
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final sutolColors = context.sutolColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sutolColors.outline.withValues(alpha: 0.5), width: 1),
        boxShadow: SutolElevation.level1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: sutolColors.seed),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: sutolColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
