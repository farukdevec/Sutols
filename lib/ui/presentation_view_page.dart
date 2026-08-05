import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'design/design_system.dart';

class PresentationViewPage extends StatefulWidget {
  const PresentationViewPage({super.key, required this.presentationId});

  final String presentationId;

  @override
  State<PresentationViewPage> createState() => _PresentationViewPageState();
}

class _PresentationViewPageState extends State<PresentationViewPage> {
  static const String _apiBase =
      'https://firestore.googleapis.com/v1/projects/sutols/databases/(default)/documents';

  late final Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchPresentation(widget.presentationId);
  }

  Future<Map<String, dynamic>> _fetchPresentation(String presentationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Lütfen önce giriş yapın.');
    }

    final idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse('$_apiBase/presentations/$presentationId'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Sunum yüklenemedi (HTTP ${response.statusCode}): ${response.body}');
    }

    final doc = jsonDecode(response.body) as Map<String, dynamic>;
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};

    return {
      'topic': _stringField(fields, 'topic'),
      'slides': _slidesField(fields['slides']),
    };
  }

  static List<Map<String, dynamic>> _slidesField(dynamic field) {
    final values = field?['arrayValue']?['values'] as List? ?? const [];
    return values.map((value) {
      final fields =
          (value as Map<String, dynamic>)['mapValue']?['fields'] as Map<String, dynamic>? ?? {};
      return {
        'title': _stringField(fields, 'title'),
        'content': _stringField(fields, 'content'),
        'layout': _stringField(fields, 'layout'),
        'modelIds': _stringArrayField(fields, 'modelIds'),
      };
    }).toList();
  }

  static String _stringField(Map<String, dynamic> fields, String key) {
    return fields[key]?['stringValue'] as String? ?? '';
  }

  static List<String> _stringArrayField(Map<String, dynamic> fields, String key) {
    final values = fields[key]?['arrayValue']?['values'] as List? ?? const [];
    return values
        .map((v) => (v as Map<String, dynamic>)['stringValue'] as String? ?? '')
        .where((v) => v.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Sunum'),
        backgroundColor: colors.surface,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s32),
                child: Text(
                  'Sunum yüklenemedi: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Text(
                'Sunum bulunamadı.',
                style: AppTypography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            );
          }

          final slides = (data['slides'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s32),
            children: [
              Text(
                data['topic'] as String? ?? '',
                style: AppTypography.headline.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                '${slides.length} slayt • ${widget.presentationId}',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              for (final slide in slides)
                _SlideCard(
                  index: slides.indexOf(slide) + 1,
                  slide: slide,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({required this.index, required this.slide});

  final int index;
  final Map<String, dynamic> slide;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final modelIds = (slide['modelIds'] as List?)?.cast<String>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$index',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  slide['title'] as String? ?? '',
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            slide['content'] as String? ?? '',
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              Chip(
                label: Text('Layout: ${slide['layout'] ?? '-'}'),
                visualDensity: VisualDensity.compact,
              ),
              if (modelIds.isNotEmpty)
                Chip(
                  label: Text('${modelIds.length} model'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
