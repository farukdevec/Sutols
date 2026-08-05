import 'dart:convert';

import 'package:http/http.dart' as http;

class AiSlideContent {
  final String title;
  final String body;
  final String speakerNotes;

  const AiSlideContent({
    required this.title,
    required this.body,
    this.speakerNotes = '',
  });
}

class AiResearchResult {
  final String title;
  final String snippet;
  final String url;

  const AiResearchResult({
    required this.title,
    required this.snippet,
    required this.url,
  });
}

class AiAnalysisItem {
  final String title;
  final String content;

  const AiAnalysisItem({
    required this.title,
    required this.content,
  });
}

class AiAnalysisResponse {
  final List<AiAnalysisItem> swot;
  final List<AiAnalysisItem> keyStatistics;
  final List<AiAnalysisItem> trends;
  final List<AiAnalysisItem> recommendations;
  final String summary;

  const AiAnalysisResponse({
    required this.swot,
    required this.keyStatistics,
    required this.trends,
    required this.recommendations,
    required this.summary,
  });
}

class AiResearchResponse {
  final List<AiResearchResult> results;
  final String summary;

  const AiResearchResponse({
    required this.results,
    required this.summary,
  });
}

class AiService {
  AiService({this.baseUrl = 'http://localhost:8765'});

  final String baseUrl;

  Future<bool> checkHealth() async {
    try {
      final resp = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['ollama_connected'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<String> generate(String prompt, {String? system, double temperature = 0.3}) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        if (system != null) 'system': system,
        'temperature': temperature,
      }),
    ).timeout(const Duration(seconds: 120));

    if (resp.statusCode != 200) {
      throw Exception('API hatasi: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['text'] as String;
  }

  Future<AiAnalysisResponse> analyze(String topic, {String language = 'turkish'}) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic': topic,
        'language': language,
      }),
    ).timeout(const Duration(seconds: 180));

    if (resp.statusCode != 200) {
      throw Exception('Analiz hatasi: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return AiAnalysisResponse(
      swot: (data['swot'] as List).map((i) => AiAnalysisItem(
        title: i['title'] as String,
        content: i['content'] as String,
      )).toList(),
      keyStatistics: (data['key_statistics'] as List).map((i) => AiAnalysisItem(
        title: i['title'] as String,
        content: i['content'] as String,
      )).toList(),
      trends: (data['trends'] as List).map((i) => AiAnalysisItem(
        title: i['title'] as String,
        content: i['content'] as String,
      )).toList(),
      recommendations: (data['recommendations'] as List).map((i) => AiAnalysisItem(
        title: i['title'] as String,
        content: i['content'] as String,
      )).toList(),
      summary: data['summary'] as String,
    );
  }

  Future<AiResearchResponse> research(String topic, {int maxResults = 5}) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/research'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic': topic,
        'max_results': maxResults,
      }),
    ).timeout(const Duration(seconds: 120));

    if (resp.statusCode != 200) {
      throw Exception('Arastirma hatasi: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = (data['results'] as List).map((r) => AiResearchResult(
      title: r['title'] as String,
      snippet: r['snippet'] as String,
      url: r['url'] as String,
    )).toList();

    return AiResearchResponse(
      results: results,
      summary: data['summary'] as String,
    );
  }

  Future<List<AiSlideContent>> generateSlides(String topic, {int slideCount = 5, String language = 'turkish'}) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/generate-slides'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic': topic,
        'slide_count': slideCount,
        'language': language,
      }),
    ).timeout(const Duration(seconds: 180));

    if (resp.statusCode != 200) {
      throw Exception('Slayt uretimi hatasi: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final slides = (data['slides'] as List).map((s) => AiSlideContent(
      title: s['title'] as String,
      body: s['body'] as String,
      speakerNotes: s['speaker_notes'] as String? ?? '',
    )).toList();

    return slides;
  }
}
