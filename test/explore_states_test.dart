import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/screens/explore_jobs/widgets/explore_states.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/shared/theme/app_theme.dart';

void main() {
  Widget localized(Widget child) => MaterialApp(
    key: UniqueKey(),
    theme: AppThemeData.light(),
    darkTheme: AppThemeData.dark(),
    themeMode: ThemeMode.dark,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );

  testWidgets('jobs states distinguish empty, error and dark loading', (
    tester,
  ) async {
    final state = ValueNotifier<Widget>(const ExploreEmptyState());
    addTearDown(state.dispose);
    await tester.pumpWidget(
      localized(
        ValueListenableBuilder<Widget>(
          valueListenable: state,
          builder: (_, value, _) => SingleChildScrollView(child: value),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('لا توجد وظائف'), findsOneWidget);
    expect(
      find.text('لا توجد حالياً وظائف تطابق بحثك أو عوامل التصفية المحددة.'),
      findsOneWidget,
    );
    expect(find.byType(ModernRetryButton), findsNothing);

    state.value = ExploreErrorState(onRetry: () {});
    await tester.pump();

    final renderedTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .whereType<String>()
        .toList();
    expect(
      renderedTexts,
      contains('تعذر تحميل الوظائف'),
      reason: 'Rendered text: $renderedTexts',
    );
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.byType(ModernRetryButton), findsOneWidget);

    state.value = const ExploreLoadingState();
    await tester.pump();

    final decoratedColors = tester
        .widgetList<Container>(find.byType(Container))
        .map((container) => container.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.color)
        .whereType<Color>();
    expect(decoratedColors, isNot(contains(Colors.white)));
  });
}
