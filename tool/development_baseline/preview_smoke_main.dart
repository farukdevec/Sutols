// Local browser regression fixture. Never expose this as a production route.
// No Firebase initialization, account data, inference or persistence requests.
import 'package:flutter/material.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/presentation_preview_page.dart';

final _errors = ValueNotifier<List<String>>(const []);

void main() {
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    _errors.value = [..._errors.value.take(7), message];
    debugPrint(message);
  };
  runApp(const MaterialApp(home: _PreviewSmoke()));
}

class _PreviewSmoke extends StatefulWidget {
  const _PreviewSmoke();
  @override
  State<_PreviewSmoke> createState() => _PreviewSmokeState();
}

class _PreviewSmokeState extends State<_PreviewSmoke> {
  final _controller = PresentationController();
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _controller.replaceDeck(const [
      PresentationPage(id: 'local-preview-smoke', textBlocks: [
        PresentationTextBlock(
            id: 'title',
            text: 'Local preview regression',
            position: Offset(.07, .15),
            fontSize: 48,
            type: PresentationTextType.title,
            widthFactor: .86),
        PresentationTextBlock(
            id: 'body',
            text: 'Text and model must remain visible.',
            position: Offset(.07, .4),
            fontSize: 30,
            type: PresentationTextType.body,
            widthFactor: .4),
      ], componentBlocks: [
        PresentationComponentBlock(
            id: 'water',
            modelAssetId: 'sutols-water-molecule',
            position: Offset(.53, .27),
            size: Size(.4, .6)),
      ]),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        TickerMode(
            enabled: _active,
            child: PresentationPreviewPage(
                controller: _controller, useFullscreen: false)),
        Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Material(
                color: Colors.amber.shade100,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextButton(
                      onPressed: () => setState(() => _active = !_active),
                      child: Text(_active ? 'Suspend scene' : 'Resume scene')),
                  ValueListenableBuilder<List<String>>(
                      valueListenable: _errors,
                      builder: (context, errors, _) => Text(errors.isEmpty
                          ? 'No Flutter runtime errors'
                          : errors.join('\n'))),
                ]))),
      ]);
}
