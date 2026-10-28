import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_intake_review.dart';
import 'package:sutol/ui/admin/admin_model_review_page.dart';

Map<String, dynamic> receipt({int warnings = 0, bool rejected = false}) => {
      'schema': 1,
      'state': rejected ? 'rejected' : 'awaiting-review',
      'metadata': {
        'id': 'test-bohr',
        'name': 'Bohr',
        'category': 'Fizik',
        'license': 'Fixture license',
        'source': 'Sutols fixture',
        'author': 'Test'
      },
      for (final key in ['modelSha256', 'thumbnailSha256', 'metadataSha256'])
        key: 'a' * 64,
      'bytes': 1000,
      'triangles': 100,
      'warnings': warnings,
      'blockers': rejected ? <String>['Invalid geometry'] : <String>[],
    };
void main() {
  test('approval requires visual, rights and warning review', () {
    final model = ModelIntakeReceipt.parse(jsonEncode(receipt(warnings: 1)));
    expect(
        () => model.decision(
            reviewer: 'Reviewer',
            accepted: true,
            visualReviewed: true,
            licenseReviewed: false,
            warningsReviewed: true,
            notes: ''),
        throwsFormatException);
    expect(
        () => model.decision(
            reviewer: 'Reviewer',
            accepted: true,
            visualReviewed: true,
            licenseReviewed: true,
            warningsReviewed: false,
            notes: ''),
        throwsFormatException);
    expect(
        model.decision(
            reviewer: 'Reviewer',
            accepted: true,
            visualReviewed: true,
            licenseReviewed: true,
            warningsReviewed: true,
            notes: 'Checked')['publicationStatus'],
        'local-review-only');
  });
  test('invalid or rejected receipts never become approval authority', () {
    for (final source in [
      '{}',
      'not json',
      jsonEncode({...receipt(), 'modelSha256': 'bad'}),
      jsonEncode({...receipt(), 'bytes': -1})
    ]) {
      expect(() => ModelIntakeReceipt.parse(source), throwsFormatException);
    }
    final model = ModelIntakeReceipt.parse(jsonEncode(receipt(rejected: true)));
    expect(model.canReview, isFalse);
    expect(
        () => model.decision(
            reviewer: 'Reviewer',
            accepted: true,
            visualReviewed: true,
            licenseReviewed: true,
            warningsReviewed: true,
            notes: ''),
        throwsFormatException);
    expect(
        model.decision(
            reviewer: 'Reviewer',
            accepted: false,
            visualReviewed: false,
            licenseReviewed: false,
            warningsReviewed: false,
            notes: 'Invalid')['decision'],
        'reject');
  });
  for (final width in [320.0, 1200.0]) {
    testWidgets('review page gates decisions and fits ${width}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      String? saved;
      await tester.pumpWidget(MaterialApp(
          home: AdminModelReviewPage(
              loadReceipt: () async => jsonEncode(receipt(warnings: 1)),
              saveDecision: (source, name) async => saved = source)));
      await tester.tap(find.byKey(const ValueKey('load-model-receipt')));
      await tester.pumpAndSettle();
      final scroller = find
          .descendant(
              of: find.byType(ListView), matching: find.byType(Scrollable))
          .first;
      FilledButton accept() =>
          tester.widget(find.byKey(const ValueKey('accept-model-review')));
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('accept-model-review')), 300,
          scrollable: scroller);
      expect(accept().onPressed, isNull);
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('model-reviewer-name')), -300,
          scrollable: scroller);
      await tester.enterText(
          find.byKey(const ValueKey('model-reviewer-name')), 'Reviewer');
      for (final label in [
        'Modeli ve küçük resmi önizlemede kontrol ettim.',
        'Kaynak ve lisansın kullanıma uygunluğunu doğruladım.',
        'Doğrulama uyarılarını inceledim.'
      ]) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }
      expect(accept().onPressed, isNotNull);
      await tester
          .ensureVisible(find.byKey(const ValueKey('accept-model-review')));
      await tester.tap(find.byKey(const ValueKey('accept-model-review')));
      await tester.pumpAndSettle();
      expect(jsonDecode(saved!)['licenseReviewed'], true);
      expect(jsonDecode(saved!)['decision'], 'accept');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('invalid replacement clears the previous review', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: AdminModelReviewPage(
            loadReceipt: () async =>
                calls++ == 0 ? jsonEncode(receipt()) : '{}')));
    await tester.tap(find.byKey(const ValueKey('load-model-receipt')));
    await tester.pumpAndSettle();
    expect(find.text('Bohr'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('load-model-receipt')));
    await tester.pumpAndSettle();
    expect(find.text('Bohr'), findsNothing);
    expect(find.byKey(const ValueKey('accept-model-review')), findsNothing);
  });
}
