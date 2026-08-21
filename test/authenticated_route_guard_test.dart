import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/ui/widgets/authenticated_route_guard.dart';

void main() {
  testWidgets('oturumu olmayan kullanıcıyı ana sayfaya yönlendirir',
      (tester) async {
    final authStates = StreamController<bool>();
    addTearDown(authStates.close);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/editor',
        routes: <String, WidgetBuilder>{
          '/': (_) => const Scaffold(
                key: ValueKey<String>('public-home'),
              ),
          '/editor': (_) => AuthenticatedRouteGuard(
                authStateStream: authStates.stream,
                builder: (_) => const Scaffold(
                  key: ValueKey<String>('protected-editor'),
                ),
              ),
        },
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    authStates.add(false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('public-home')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('protected-editor')),
      findsNothing,
    );
  });

  testWidgets('oturumu olan kullanıcıya korunan sayfayı gösterir',
      (tester) async {
    final authStates = StreamController<bool>();
    addTearDown(authStates.close);

    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticatedRouteGuard(
          authStateStream: authStates.stream,
          builder: (_) => const Scaffold(
            key: ValueKey<String>('protected-editor'),
          ),
        ),
      ),
    );

    authStates.add(true);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('protected-editor')),
      findsOneWidget,
    );
  });
}
