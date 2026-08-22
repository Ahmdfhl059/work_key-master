import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:work_key/data/repo/application_repo.dart';
import 'package:work_key/data/repo/auth_repo.dart';
import 'package:work_key/data/repo/cv_repo.dart';
import 'package:work_key/data/repo/interviews_repo.dart';
import 'package:work_key/data/repo/jobs_repo.dart';
import 'package:work_key/data/repo/notifications_repo.dart';
import 'package:work_key/data/repo/profile_repo.dart';
import 'package:work_key/data/repo/tests_repo.dart';
import 'package:work_key/logic/application_cubit/application_cubit.dart';
import 'package:work_key/logic/auth_cubit/auth_cubit.dart';
import 'package:work_key/logic/cv_cubit/cv_cubit.dart';
import 'package:work_key/logic/home_cubit/home_cubit.dart';
import 'package:work_key/logic/interviews_cubit/interviews_cubit.dart';
import 'package:work_key/logic/job_cubit/job_cubit.dart';
import 'package:work_key/logic/local_cubit/local_cubit.dart';
import 'package:work_key/logic/local_cubit/local_state.dart';
import 'package:work_key/logic/notifications_cubit/notifications_cubit.dart';
import 'package:work_key/logic/profile_cubit/profile_cubit.dart';
import 'package:work_key/logic/tests_cubit/tests_cubit.dart';
import 'package:work_key/logic/theme_cubit/theme_cubit.dart';
import 'package:work_key/logic/theme_cubit/theme_state.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/shared/theme/app_theme.dart';
import 'package:work_key/screens/auth/SplashScreen.dart';
import 'package:work_key/utils/shared%20preferences.dart';
import 'package:work_key/data/repo/home_repo.dart';
import 'package:work_key/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await PushNotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(AuthRepo())),
        BlocProvider(create: (context) => JobCubit(JobsRepo())),
        BlocProvider(create: (context) => ProfileCubit(ProfileRepo())),
        BlocProvider(create: (context) => ApplicationCubit(ApplicationRepo())),
        BlocProvider(create: (context) => TestsCubit(TestsRepo())),
        BlocProvider(create: (context) => InterviewsCubit(InterviewsRepo())),
        BlocProvider(
          create: (context) => NotificationsCubit(NotificationsRepo()),
        ),
        BlocProvider(create: (context) => CvCubit(CvRepo())),
        BlocProvider(create: (context) => HomeCubit(HomeRepo())),
        BlocProvider(create: (context) => LocaleCubit()..getSavedLanguage()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) => BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final locale = localeState is ChangeLocaleState
                ? localeState.locale
                : const Locale('en');
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppThemeData.light(),
              darkTheme: AppThemeData.dark(),
              themeMode: themeState.mode,
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('ar')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
