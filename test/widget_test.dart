import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_key/main.dart';
import 'package:work_key/screens/auth/SplashScreen.dart';
import 'package:work_key/utils/shared%20preferences.dart';

void main() {
  testWidgets('app starts from the splash screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();

    await tester.pumpWidget(const MyApp());

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
