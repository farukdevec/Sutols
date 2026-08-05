import 'package:flutter/material.dart';

import '../../services/ai_service.dart';
import '../design/design_system.dart';

class SourceSelectionResult {
  const SourceSelectionResult({
    required this.selectedResults,
    this.includeAnalysis = true,
  });

  final List<AiResearchResult> selectedResults;
  final bool includeAnalysis;
}

class SourceSelector extends StatefulWidget {
  const SourceSelector({
    super.key,
    required this.results,
    required this.topic,
    required this.onConfirm,
  });

  final List<AiResearchResult> results;
  final String topic;
  final void Function(SourceSelectionResult) onConfirm;

  @override
  State<SourceSelector> createState() => _SourceSelectorState();
}

class _SourceSelectorState extends State<SourceSelector> {
  final Set<int> _selectedIndices = <int>{};
  bool _includeAnalysis = true;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.results.length; i++) {
      _selectedIndices.add(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.source_rounded, color: colors.accent, size: 24),
              const SizedBox(width: 10),
              Text(
                'Kaynak Seçimi',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${widget.topic}" için bulunan kaynaklardan sunuma dahil edilecekleri seçin.',
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: widget.results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final result = widget.results[index];
                final selected = _selectedIndices.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedIndices.remove(index);
                      } else {
                        _selectedIndices.add(index);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.accent.withValues(alpha: 0.08)
                          : colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? colors.accent : colors.border.withValues(alpha: 0.5),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? colors.accent : Colors.transparent,
                            border: Border.all(
                              color: selected ? colors.accent : colors.border,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result.snippet,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result.url,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 36,
                child: Checkbox(
                  value: _includeAnalysis,
                  onChanged: (v) => setState(() => _includeAnalysis = v ?? true),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Stratejik analiz (SWOT, trendler, öneriler) ekle',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _selectedIndices.length < widget.results.length
                      ? () {
                          setState(() {
                            for (var i = 0; i < widget.results.length; i++) {
                              _selectedIndices.add(i);
                            }
                          });
                        }
                      : null,
                  child: const Text('Tümünü Seç'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _selectedIndices.isEmpty
                      ? null
                      : () {
                          widget.onConfirm(SourceSelectionResult(
                            selectedResults: _selectedIndices.map(
                              (i) => widget.results[i],
                            ).toList(),
                            includeAnalysis: _includeAnalysis,
                          ));
                        },
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text('Devam Et'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
