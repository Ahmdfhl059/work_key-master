import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/screens/auth/login/widgets/login_header.dart';
import 'package:work_key/screens/auth/register/widgets/register_header.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/shared/theme/app_theme.dart';

void main() {
  testWidgets('auth logo, text field, labels and icons follow dark colors', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final theme = AppThemeData.dark();
    final colors = theme.colorScheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const LoginHeader(),
                CustomTextField(
                  controller: controller,
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const RegisterHeader(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNWidgets(2));
    expect(
      tester.widget<TextField>(find.byType(TextField)).style?.color,
      colors.onSurface,
    );
    expect(
      tester.widget<Text>(find.text('Password')).style?.color,
      colors.onSurface,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.visibility_off).first).color,
      colors.onSurfaceVariant,
    );
    expect(
      tester
          .widget<Text>(find.text('Sign in to discover your next opportunity.'))
          .style
          ?.color,
      colors.onSurfaceVariant,
    );
  });
}
