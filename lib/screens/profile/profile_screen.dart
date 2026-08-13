import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/profile_model.dart';
import 'package:work_key/logic/auth_cubit/auth_cubit.dart';
import 'package:work_key/logic/auth_cubit/auth_state.dart';
import 'package:work_key/logic/local_cubit/local_cubit.dart';
import 'package:work_key/logic/profile_cubit/profile_cubit.dart';
import 'package:work_key/logic/profile_cubit/profile_state.dart';
import 'package:work_key/logic/cv_cubit/cv_cubit.dart';
import 'package:work_key/screens/auth/login/login_screen.dart';
import 'package:work_key/screens/profile/profile_strings.dart';
import 'package:work_key/screens/profile/widgets/profile_edit_sheet.dart';
import 'package:work_key/screens/profile/widgets/profile_sections.dart';
import 'package:work_key/screens/profile/widgets/profile_cv_section.dart';
import 'package:work_key/screens/profile/widgets/profile_manage_sheets.dart';
import 'package:work_key/screens/interviews/interviews_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileModel? profile;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().getProfile();
      context.read<CvCubit>().getCvFiles();
    });
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is LogoutSuccessState) {
            navigateAndFinish(context, const LoginScreen());
          }
        },
      ),
      BlocListener<ProfileCubit, ProfileStates>(
        listener: (context, state) {
          if (state is GetProfileSuccessState) {
            setState(() => profile = state.profileModel);
          }
          if (state is UpdateProfileSuccessState) {
            setState(() => profile = state.profileModel);
          }
        },
      ),
    ],
    child: Material(
      color: HomeColors.canvas,
      child: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          final strings = ProfileStrings.of(context);
          if (profile == null && state is ProfileLoadingState) {
            return const _ProfileLoading();
          }
          if (profile == null && state is ProfileErrorState) {
            return _ProfileError(
              message: 'Unable to load your profile.',
              retry: context.read<ProfileCubit>().getProfile,
            );
          }
          if (profile == null) return const _ProfileLoading();
          return RefreshIndicator(
            onRefresh: () async => context.read<ProfileCubit>().getProfile(),
            child: ResponsiveContent(
              maxWidth: 760,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(top: 18, bottom: 125),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DefaultText(
                          text: strings.title,
                          style: const TextStyle(
                            color: HomeColors.ink,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      DefaultIconButton(
                        onPressed: () => _settings(context, strings),
                        color: HomeColors.purple,
                        size: 21,
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  ProfileHero(
                    profile: profile!,
                    editLabel: strings.edit,
                    edit: () => showProfileEditSheet(context, profile!),
                    onAvatarTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profile photo upload is waiting for backend support.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ProfileOverview(
                    profile: profile!,
                    onManageSkills: () => showSkillsManager(context, profile!),
                    onManageExperience: () =>
                        showExperienceManager(context, profile!),
                    onManageEducation: () =>
                        showEducationManager(context, profile!),
                  ),
                  const SizedBox(height: 14),
                  const ProfileCvSection(),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => navigateTo(context, const InterviewsScreen()),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HomeColors.divider),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: HomeColors.softPurple,
                            child: Icon(
                              Icons.video_call_rounded,
                              color: HomeColors.purple,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DefaultText(
                                  text: 'My interviews',
                                  style: TextStyle(
                                    color: HomeColors.ink,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3),
                                DefaultText(
                                  text: 'View schedules and attendance details',
                                  style: TextStyle(
                                    color: HomeColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: HomeColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, strings),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB44343),
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: Color(0xFFE8B9B9)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(strings.logout),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Future<void> _settings(BuildContext context, ProfileStrings strings) async =>
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultText(
                    text: strings.settings,
                    style: const TextStyle(
                      color: HomeColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.language_rounded,
                      color: HomeColors.purple,
                    ),
                    title: Text(strings.language),
                    subtitle: Text(
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? 'العربية'
                          : 'English',
                    ),
                    trailing: const Icon(Icons.swap_horiz_rounded),
                    onTap: () {
                      final next =
                          Localizations.localeOf(context).languageCode == 'ar'
                          ? 'en'
                          : 'ar';
                      context.read<LocaleCubit>().changeLanguage(next);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFB44343),
                    ),
                    title: Text(
                      strings.logout,
                      style: const TextStyle(color: Color(0xFFB44343)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmLogout(context, strings);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  Future<void> _confirmLogout(
    BuildContext context,
    ProfileStrings strings,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(strings.logout),
            content: Text(
              strings.ar
                  ? 'هل أنت متأكد من تسجيل الخروج؟'
                  : 'Are you sure you want to log out?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.ar ? 'إلغاء' : 'Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(strings.logout),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && context.mounted) context.read<AuthCubit>().logout();
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();
  @override
  Widget build(BuildContext context) => Material(
    color: HomeColors.canvas,
    child: ResponsiveContent(
      maxWidth: 760,
      child: ListView(
        padding: const EdgeInsets.only(top: 18),
        children: [
          Container(
            width: 180,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(height: 17),
          Container(
            height: 225,
            decoration: BoxDecoration(
              color: HomeColors.softPurple,
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (_) => Container(
              height: 135,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileError extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const _ProfileError({required this.message, required this.retry});
  @override
  Widget build(BuildContext context) => Material(
    color: HomeColors.canvas,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 58,
              color: HomeColors.muted,
            ),
            const SizedBox(height: 12),
            DefaultText(
              text: message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: HomeColors.ink),
            ),
            const SizedBox(height: 16),
            DefaultButton(
              width: 150,
              background: HomeColors.purple,
              text: 'Try again',
              uppercase: false,
              onPress: retry,
            ),
          ],
        ),
      ),
    ),
  );
}
