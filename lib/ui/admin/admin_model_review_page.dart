import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/local_json_file.dart';
import '../../services/model_intake_review.dart';

class AdminModelReviewPage extends StatefulWidget {
  const AdminModelReviewPage({super.key, this.loadReceipt, this.saveDecision});
  final Future<String?> Function()? loadReceipt;
  final Future<void> Function(String, String)? saveDecision;
  @override
  State<AdminModelReviewPage> createState() => _AdminModelReviewPageState();
}

class _AdminModelReviewPageState extends State<AdminModelReviewPage> {
  final _reviewer = TextEditingController();
  final _notes = TextEditingController();
  ModelIntakeReceipt? _receipt;
  bool _visual = false, _license = false, _warnings = false, _busy = false;
  String? _error, _status;

  @override
  void dispose() {
    _reviewer.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
      _status = null;
    });
    try {
      final source = await (widget.loadReceipt ?? pickLocalJsonFile)();
      if (!mounted || source == null) return;
      setState(() => _receipt = null);
      final receipt = ModelIntakeReceipt.parse(source);
      setState(() {
        _receipt = receipt;
        _visual = false;
        _license = false;
        _warnings = false;
        _notes.clear();
      });
    } catch (_) {
      if (mounted)
        setState(() => _error =
            'Karantina raporu okunamadı. Dosyanın doğru ve eksiksiz olduğunu kontrol edin.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download(bool accepted) async {
    final receipt = _receipt;
    if (receipt == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _status = null;
    });
    try {
      final decision = receipt.decision(
          reviewer: _reviewer.text,
          accepted: accepted,
          visualReviewed: _visual,
          licenseReviewed: _license,
          warningsReviewed: _warnings,
          notes: _notes.text);
      await (widget.saveDecision ?? downloadLocalJsonFile)(
          const JsonEncoder.withIndent('  ').convert(decision),
          '${receipt.id}-review.json');
      if (mounted)
        setState(() => _status =
            'İnceleme kararı indirildi. Katalog yayını ayrı adımdır.');
    } catch (_) {
      if (mounted)
        setState(() => _error =
            'Karar indirilemedi. İnceleyen adını ve gerekli kontrolleri tamamlayın.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    final canAccept = receipt?.canReview == true &&
        _reviewer.text.trim().isNotEmpty &&
        _visual &&
        _license &&
        (receipt!.warnings == 0 || _warnings);
    return Scaffold(
      appBar: AppBar(title: const Text('Model inceleme')),
      body: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text(
              'Modelin doğrulama raporunu açın; önizlemeyi ve kullanım haklarını inceleyip kararınızı indirin.'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
              key: const ValueKey('load-model-receipt'),
              onPressed: _busy ? null : _load,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Karantina raporu aç')),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
          if (_status != null)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_status!)),
          if (receipt != null) ...[
            const SizedBox(height: 16),
            Text(receipt.name,
                style: Theme.of(context).textTheme.headlineSmall),
            Text(
                '${receipt.metadata['category']} · ${(receipt.data['bytes'] as int) / 1024 ~/ 1} KB · ${receipt.data['triangles'] ?? '?'} üçgen'),
            const SizedBox(height: 12),
            SelectableText(
                'Kaynak: ${receipt.metadata['source']}\nHak sahibi: ${receipt.metadata['author']}\nLisans: ${receipt.metadata['license']}'),
            const SizedBox(height: 12),
            Text('Doğrulama uyarısı: ${receipt.warnings}'),
            if (!receipt.canReview) ...[
              const Text(
                  'Bu başvuru onaya uygun değil. Doğrulama sorunlarını giderip tekrar hazırlayın.'),
              for (final blocker in receipt.data['blockers'] as List)
                Text('• $blocker'),
            ],
            const SizedBox(height: 16),
            TextField(
                key: const ValueKey('model-reviewer-name'),
                controller: _reviewer,
                maxLength: 200,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'İnceleyen adı')),
            CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                    'Modeli ve küçük resmi önizlemede kontrol ettim.'),
                value: _visual,
                onChanged: _busy ? null : (v) => setState(() => _visual = v!)),
            CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                    'Kaynak ve lisansın kullanıma uygunluğunu doğruladım.'),
                value: _license,
                onChanged: _busy ? null : (v) => setState(() => _license = v!)),
            if (receipt.warnings > 0)
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Doğrulama uyarılarını inceledim.'),
                  value: _warnings,
                  onChanged:
                      _busy ? null : (v) => setState(() => _warnings = v!)),
            TextField(
                controller: _notes,
                minLines: 2,
                maxLines: 5,
                maxLength: 4000,
                decoration: const InputDecoration(labelText: 'İnceleme notu')),
            const SizedBox(height: 16),
            Wrap(spacing: 12, runSpacing: 8, children: [
              FilledButton.icon(
                  key: const ValueKey('accept-model-review'),
                  onPressed: !_busy && canAccept ? () => _download(true) : null,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Onay kararını indir')),
              OutlinedButton(
                  key: const ValueKey('reject-model-review'),
                  onPressed: !_busy && _reviewer.text.trim().isNotEmpty
                      ? () => _download(false)
                      : null,
                  child: const Text('Ret kararını indir')),
            ]),
          ],
        ]),
      )),
    );
  }
}
