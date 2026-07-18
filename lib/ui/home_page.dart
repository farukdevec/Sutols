import 'package:flutter/material.dart';

import '../state/presentation_controller.dart';
import 'presentation_text_draft_page.dart';

class SutolHomePage extends StatelessWidget {
  const SutolHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF050816),
              Color(0xFF0C1424),
              Color(0xFF09101D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Sutol',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const _HtmlPresentationEntryPage(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF07101C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 34,
                    vertical: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Sunum Olustur',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlPresentationEntryPage extends StatefulWidget {
  const _HtmlPresentationEntryPage();

  @override
  State<_HtmlPresentationEntryPage> createState() =>
      _HtmlPresentationEntryPageState();
}

class _HtmlPresentationEntryPageState
    extends State<_HtmlPresentationEntryPage> {
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
