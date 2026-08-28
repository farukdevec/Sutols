import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../design/design_system.dart';

class AdminPresentationFeedbackPage extends StatelessWidget {
  const AdminPresentationFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(title: const Text('Sunum Değerlendirmeleri')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('presentation_feedback')
            .orderBy('submittedAt', descending: true)
            .limit(300)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _FeedbackMessage(
              icon: Icons.error_outline_rounded,
              message: 'Değerlendirmeler yüklenemedi.\n${snapshot.error}',
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final feedback = snapshot.data!.docs;
          if (feedback.isEmpty) {
            return const _FeedbackMessage(
              icon: Icons.rate_review_outlined,
              message: 'Henüz gönderilmiş bir değerlendirme yok.',
            );
          }
          return _FeedbackContent(feedback: feedback);
        },
      ),
    );
  }
}

class _FeedbackContent extends StatelessWidget {
  const _FeedbackContent({required this.feedback});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> feedback;

  double _average(String field) {
    final values = feedback
        .map((doc) => (doc.data()[field] as num?)?.toDouble())
        .whereType<double>();
    if (values.isEmpty) return 0;
    return values.reduce((sum, value) => sum + value) / values.length;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      children: [
        Text('Yapay zekâ ile oluşturulan sunumların kullanıcı değerlendirmeleri', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
        const SizedBox(height: AppSpacing.s16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 920 ? 4 : constraints.maxWidth >= 560 ? 2 : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: AppSpacing.s12,
              mainAxisSpacing: AppSpacing.s12,
              childAspectRatio: 2.25,
              children: [
                _AverageCard(title: 'Modeller', icon: Icons.smart_toy_outlined, value: _average('modelRating')),
                _AverageCard(title: 'Metinler', icon: Icons.subject_rounded, value: _average('textRating')),
                _AverageCard(title: 'Görseller', icon: Icons.image_outlined, value: _average('visualRating')),
                _AverageCard(title: 'Şablon', icon: Icons.dashboard_customize_outlined, value: _average('templateRating')),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.s28),
        Text('${feedback.length} değerlendirme', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
        const SizedBox(height: AppSpacing.s12),
        ...feedback.map((doc) => _FeedbackCard(data: doc.data())),
      ],
    );
  }
}

class _AverageCard extends StatelessWidget {
  const _AverageCard({required this.title, required this.icon, required this.value});
  final String title;
  final IconData icon;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(title, style: AppTypography.labelMedium.copyWith(color: colors.textSecondary)),
            const SizedBox(height: 3),
            Row(children: [Text(value.toStringAsFixed(1), style: AppTypography.titleLarge.copyWith(color: colors.textPrimary)), const SizedBox(width: 3), const Icon(Icons.star_rounded, size: 19, color: Color(0xFFFFB300))]),
          ])),
        ]),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.data});
  final Map<String, dynamic> data;

  String _date() {
    final timestamp = data['submittedAt'];
    if (timestamp is! Timestamp) return 'Az önce';
    final value = timestamp.toDate().toLocal();
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final note = (data['note'] as String? ?? '').trim();
    final id = data['presentationId'] as String? ?? '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.slideshow_outlined, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text('Sunum: $id', overflow: TextOverflow.ellipsis, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600))),
              Text(_date(), style: AppTypography.labelMedium.copyWith(color: colors.textSecondary)),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 16, runSpacing: 8, children: [
              _RatingChip(label: 'Model', value: data['modelRating']),
              _RatingChip(label: 'Metin', value: data['textRating']),
              _RatingChip(label: 'Görsel', value: data['visualRating']),
              _RatingChip(label: 'Şablon', value: data['templateRating']),
            ]),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Text(note, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, height: 1.4)),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.label, required this.value});
  final String label;
  final dynamic value;
  @override
  Widget build(BuildContext context) {
    final rating = (value as num?)?.toInt() ?? 0;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label ', style: AppTypography.labelMedium.copyWith(color: context.colors.textSecondary)),
      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
      Text(' $rating/5', style: AppTypography.labelMedium.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _FeedbackMessage extends StatelessWidget {
  const _FeedbackMessage({required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 42, color: context.colors.textSecondary), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center, style: AppTypography.bodyLarge.copyWith(color: context.colors.textSecondary))]));
}
