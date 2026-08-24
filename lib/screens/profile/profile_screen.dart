import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_key/data/models/profile_model.dart';
import 'package:work_key/logic/auth_cubit/auth_cubit.dart';
import 'package:work_key/logic/auth_cubit/auth_state.dart';
import 'package:work_key/logic/local_cubit/local_cubit.dart';
import 'package:work_key/logic/theme_cubit/theme_cubit.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/logic/profile_cubit/profile_cubit.dart';
import 'package:work_key/logic/profile_cubit/profile_state.dart';
import 'package:work_key/logic/cv_cubit/cv_cubit.dart';
import 'package:work_key/logic/cv_cubit/cv_state.dart';
import 'package:work_key/screens/auth/login/login_screen.dart';
import 'package:work_key/screens/profile/profile_strings.dart';
import 'package:work_key/screens/profile/widgets/profile_edit_sheet.dart';
import 'package:work_key/screens/profile/widgets/profile_sections.dart';
import 'package:work_key/screens/profile/widgets/profile_cv_section.dart';
import 'package:work_key/screens/profile/widgets/profile_manage_sheets.dart';
import 'package:work_key/screens/interviews/interviews_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/shared/components/app_snackbar.dart';
import 'package:work_key/utils/constants.dart';

part 'widgets/profile_screen/states.dart';

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
      BlocListener<CvCubit, CvState>(
        listenWhen: (previous, current) =>
            previous.profileChanged != current.profileChanged ||
            previous.message != current.message ||
            previous.error != current.error,
        listener: (context, state) {
          if (state.profileChanged) {
            context.read<ProfileCubit>().getProfile();
          }
          final feedback = state.error ?? state.message;
          if (feedback != null && feedback.isNotEmpty) {
            final localized = feedback.startsWith('cv.')
                ? context.tr(feedback)
                : feedback;
            if (state.error != null) {
              AppSnackBar.error(context, localized);
            } else {
              AppSnackBar.success(context, localized);
            }
            context.read<CvCubit>().consumeFeedback();
          }
        },
      ),
    ],
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      child: BlocBuilder<ProfileCubit, ProfileStates>(
        builder: (context, state) {
          final strings = ProfileStrings.of(context);
          if (profile == null && state is ProfileLoadingState) {
            return const _ProfileLoading();
          }
          if (profile == null && state is ProfileErrorState) {
            return _ProfileError(
              message: context.tr('profile.load_error'),
              retry: context.read<ProfileCubit>().getProfile,
            );
          }
          if (profile == null) return const _ProfileLoading();
          return RefreshIndicator(
            onRefresh: () async => context.read<ProfileCubit>().getProfile(),
            child: ResponsiveContent(
              maxWidth: 760,
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          style: TextStyle(
                            color: context.appInk,
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
                  const ProfileCvSection(),
                  const SizedBox(height: 16),
                  ProfileHero(
                    profile: profile!,
                    editLabel: strings.edit,
                    edit: () => showProfileEditSheet(context, profile!),
                    uploadAvatar: _pickAvatar,
                  ),
                  const SizedBox(height: 16),
                  ProfileOverview(
                    profile: profile!,
                    onEditProfile: () =>
                        showProfileEditSheet(context, profile!),
                    onManageSkills: () => showSkillsManager(context, profile!),
                    onManageExperience: () =>
                        showExperienceManager(context, profile!),
                    onManageEducation: () =>
                        showEducationManager(context, profile!),
                  ),
                  const SizedBox(height: 14),
                  AnimatedPressableCard(
                    onTap: () => navigateTo(context, const InterviewsScreen()),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.surfaceContainer,
                            Theme.of(context).colorScheme.primaryContainer
                                .withValues(alpha: .32),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: context.appSoftBrand,
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
                                  text: context.tr('interviews.title'),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3),
                                DefaultText(
                                  text: context.tr('interviews.profile_hint'),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: Theme.of(context).colorScheme.primary,
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

  Future<void> _pickAvatar() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(context.tr('profile.choose_gallery')),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              if (profile?.user.avatarUrl != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFB44343),
                  ),
                  title: Text(context.tr('common.delete')),
                  onTap: () => Navigator.pop(context, 'delete'),
                ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(context.tr('profile.take_photo')),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'delete') {
      if (profile?.user.avatarUrl != null) {
        final removed = await context.read<ProfileCubit>().deleteAvatar();
        if (removed && mounted) {
          PaintingBinding.instance.imageCache
            ..clear()
            ..clearLiveImages();
        }
      }
      return;
    }
    final source = choice == 'camera'
        ? ImageSource.camera
        : ImageSource.gallery;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (image == null || !mounted) return;
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    await context.read<ProfileCubit>().uploadAvatar(image.path);
    if (mounted) context.read<ProfileCubit>().getProfile();
  }

  Future<void> _settings(BuildContext context, ProfileStrings strings) async =>
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => Material(
          color: Theme.of(context).colorScheme.surface,
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
                    style: TextStyle(
                      color: context.appInk,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: HomeColors.purple,
                    ),
                    title: Text(context.tr('settings.theme')),
                    subtitle: Text(
                      Theme.of(context).brightness == Brightness.dark
                          ? context.tr('settings.dark')
                          : context.tr('settings.light'),
                    ),
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (dark) =>
                          context.read<ThemeCubit>().toggle(dark),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.devices_outlined,
                      color: Color(0xFFB44343),
                    ),
                    title: Text(
                      context.tr('auth.logout_all'),
                      style: const TextStyle(color: Color(0xFFB44343)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmLogoutAll(context, strings);
                    },
                  ),
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

  Future<void> _confirmLogoutAll(
    BuildContext context,
    ProfileStrings strings,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(context.tr('auth.logout_all')),
            content: Text(context.tr('auth.logout_all_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(context.tr('common.cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(context.tr('auth.logout_all')),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && context.mounted) context.read<AuthCubit>().logoutAll();
  }

  Future<void> _confirmLogout(
    BuildContext context,
    ProfileStrings strings,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(strings.logout),
            content: Text(context.tr('auth.logout_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.tr('common.cancel')),
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
