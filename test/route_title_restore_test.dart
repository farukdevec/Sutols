import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/routes.dart';

void main() {
  testWidgets('popping FAQ restores the home title', (tester) async {
    final titles = <String>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemChrome.setApplicationSwitcherDescription') {
        titles.add((call.arguments as Map)['label'] as String);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: key,
      navigatorObservers: [SutolsRouteTitleObserver()],
      routes: {
        '/': (_) => const Scaffold(body: Text('Home')),
        '/sss': (_) => Title(
            title: 'SSS',
            color: Colors.black,
            child: Scaffold(body: Text('FAQ'))),
      },
    ));
    key.currentState!.pushNamed('/sss');
    await tester.pumpAndSettle();
    expect(titles.last, 'SSS');
    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(titles.last, 'Sutols');
  });
}
