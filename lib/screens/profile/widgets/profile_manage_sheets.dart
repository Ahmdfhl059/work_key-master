import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/education_model.dart';
import 'package:work_key/data/models/experience_model.dart';
import 'package:work_key/data/models/profile_model.dart';
import 'package:work_key/logic/profile_cubit/profile_cubit.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/shared/components/app_snackbar.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

part 'profile_manage/manager_widgets.dart';
part 'profile_manage/experience_form.dart';
part 'profile_manage/education_form.dart';
part 'profile_manage/skill_search.dart';

Future<void> showExperienceManager(BuildContext context, ProfileModel profile) {
  return _showManager(
    context,
    title: context.tr('profile.manage_experience'),
    items: profile.experiences
        .map(
          (item) => _ManageItem(
            title: item.title,
            subtitle: item.companyName,
            onEdit: () => _experienceForm(context, item),
            onDelete: () async {
              final deleted = await context
                  .read<ProfileCubit>()
                  .deleteExperience(item.id);
              if (deleted && context.mounted) Navigator.pop(context);
            },
          ),
        )
        .toList(),
    onAdd: () => _experienceForm(context, null),
  );
}

Future<void> showEducationManager(BuildContext context, ProfileModel profile) {
  return _showManager(
    context,
    title: context.tr('profile.manage_education'),
    items: profile.education
        .map(
          (item) => _ManageItem(
            title: item.degree.isEmpty ? item.fieldOfStudy : item.degree,
            subtitle: item.institution,
            onEdit: () => _educationForm(context, item),
            onDelete: () async {
              final deleted = await context
                  .read<ProfileCubit>()
                  .deleteEducation(item.id);
              if (deleted && context.mounted) Navigator.pop(context);
            },
          ),
        )
        .toList(),
    onAdd: () => _educationForm(context, null),
  );
}

Future<void> showSkillsManager(BuildContext context, ProfileModel profile) {
  final cubit = context.read<ProfileCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ManagerHeader(title: context.tr('profile.manage_skills')),
                const SizedBox(height: 12),
                if (profile.skills.isNotEmpty)
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: profile.skills
                        .map(
                          (skill) => InputChip(
                            label: Text(skill.name),
                            onDeleted: () async {
                              final deleted = await cubit.detachSkill(skill.id);
                              if (deleted && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 16),
                DefaultButton(
                  background: HomeColors.purple,
                  text: context.tr('profile.add_skill'),
                  uppercase: false,
                  onPress: () async {
                    final skills = await cubit.availableSkills();
                    if (!context.mounted) return;
                    final selected = await showSearch<int?>(
                      context: context,
                      delegate: _SkillSearch(skills),
                    );
                    if (selected != null) {
                      final attached = await cubit.attachSkill(selected);
                      if (attached && context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _showManager(
  BuildContext context, {
  required String title,
  required List<_ManageItem> items,
  required VoidCallback onAdd,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ManagerHeader(title: title),
              Flexible(
                child: items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text(context.tr('profile.no_items')),
                      )
                    : ListView(shrinkWrap: true, children: items),
              ),
              const SizedBox(height: 12),
              DefaultButton(
                background: HomeColors.purple,
                text: context.tr('profile.add_new'),
                uppercase: false,
                onPress: onAdd,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
