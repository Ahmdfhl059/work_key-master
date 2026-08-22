import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/shared/components/animated_app_logo.dart';

void main() {
  testWidgets(
    'dark logo keeps the original mark and overlays a light wordmark',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: AdaptiveAppLogo()),
        ),
      );

      expect(find.byType(AdaptiveAppLogo), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
      expect(find.byType(ClipRect), findsOneWidget);
    },
  );

  testWidgets('light logo renders the untouched original asset once', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: const Scaffold(body: AdaptiveAppLogo()),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(ClipRect), findsNothing);
  });
}
