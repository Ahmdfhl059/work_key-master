import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/education_model.dart';
import 'package:work_key/data/models/experience_model.dart';
import 'package:work_key/data/models/profile_model.dart';
import 'package:work_key/logic/profile_cubit/profile_cubit.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

Future<void> showExperienceManager(BuildContext context, ProfileModel profile) {
  return _showManager(
    context,
    title: 'Manage experience',
    items: profile.experiences
        .map(
          (item) => _ManageItem(
            title: item.title,
            subtitle: item.companyName,
            onEdit: () => _experienceForm(context, item),
            onDelete: () async {
              await context.read<ProfileCubit>().deleteExperience(item.id);
              if (context.mounted) Navigator.pop(context);
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
    title: 'Manage education',
    items: profile.education
        .map(
          (item) => _ManageItem(
            title: item.degree.isEmpty ? item.fieldOfStudy : item.degree,
            subtitle: item.institution,
            onEdit: () => _educationForm(context, item),
            onDelete: () async {
              await context.read<ProfileCubit>().deleteEducation(item.id);
              if (context.mounted) Navigator.pop(context);
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
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ManagerHeader(title: 'Manage skills'),
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
                              await cubit.detachSkill(skill.id);
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 16),
                DefaultButton(
                  background: HomeColors.purple,
                  text: 'Add skill',
                  uppercase: false,
                  onPress: () async {
                    final skills = await cubit.availableSkills();
                    if (!context.mounted) return;
                    final selected = await showSearch<int?>(
                      context: context,
                      delegate: _SkillSearch(skills),
                    );
                    if (selected != null) {
                      await cubit.attachSkill(selected);
                      if (context.mounted) Navigator.pop(context);
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
      color: Colors.white,
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
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text('No items added yet.'),
                      )
                    : ListView(shrinkWrap: true, children: items),
              ),
              const SizedBox(height: 12),
              DefaultButton(
                background: HomeColors.purple,
                text: 'Add new',
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

class _ManagerHeader extends StatelessWidget {
  final String title;
  const _ManagerHeader({required this.title});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: DefaultText(
          text: title,
          style: const TextStyle(
            color: HomeColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded),
      ),
    ],
  );
}

class _ManageItem extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onEdit, onDelete;
  const _ManageItem({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title.isEmpty ? 'Untitled' : title),
    subtitle: subtitle.isEmpty ? null : Text(subtitle),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
        IconButton(
          onPressed: onDelete,
          color: const Color(0xFFB44343),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    ),
  );
}

Future<void> _experienceForm(
  BuildContext context,
  ExperienceModel? item,
) async {
  final title = TextEditingController(text: item?.title ?? '');
  final company = TextEditingController(text: item?.companyName ?? '');
  final location = TextEditingController(text: item?.location ?? '');
  final start = TextEditingController(text: item?.startDate ?? '');
  final end = TextEditingController(text: item?.endDate ?? '');
  final description = TextEditingController(text: item?.description ?? '');
  var current = item?.isCurrent ?? false;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(item == null ? 'Add experience' : 'Edit experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(title, 'Job title'),
              _field(company, 'Company'),
              _field(location, 'Location'),
              _field(start, 'Start date (YYYY-MM-DD)'),
              if (!current) _field(end, 'End date (YYYY-MM-DD)'),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: current,
                title: const Text('I currently work here'),
                onChanged: (value) =>
                    setDialogState(() => current = value ?? false),
              ),
              _field(description, 'Description', lines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await context.read<ProfileCubit>().saveExperience(item?.id, {
                'title': title.text.trim(),
                'company_name': company.text.trim(),
                'location': location.text.trim(),
                'start_date': start.text.trim(),
                'end_date': current ? null : end.text.trim(),
                'is_current': current,
                'description': description.text.trim(),
              });
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  for (final controller in [
    title,
    company,
    location,
    start,
    end,
    description,
  ]) {
    controller.dispose();
  }
}

Future<void> _educationForm(BuildContext context, EducationModel? item) async {
  final institution = TextEditingController(text: item?.institution ?? '');
  final degree = TextEditingController(text: item?.degree ?? '');
  final field = TextEditingController(text: item?.fieldOfStudy ?? '');
  final start = TextEditingController(text: item?.startDate ?? '');
  final end = TextEditingController(text: item?.endDate ?? '');
  final description = TextEditingController(text: item?.description ?? '');
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(item == null ? 'Add education' : 'Edit education'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(institution, 'Institution'),
            _field(degree, 'Degree'),
            _field(field, 'Field of study'),
            _field(start, 'Start date (YYYY-MM-DD)'),
            _field(end, 'End date (YYYY-MM-DD)'),
            _field(description, 'Description', lines: 3),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await context.read<ProfileCubit>().saveEducation(item?.id, {
              'institution': institution.text.trim(),
              'degree': degree.text.trim(),
              'field_of_study': field.text.trim(),
              'start_date': start.text.trim(),
              'end_date': end.text.trim(),
              'description': description.text.trim(),
            });
            if (dialogContext.mounted) Navigator.pop(dialogContext);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  for (final controller in [
    institution,
    degree,
    field,
    start,
    end,
    description,
  ]) {
    controller.dispose();
  }
}

Widget _field(
  TextEditingController controller,
  String label, {
  int lines = 1,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 9),
  child: TextField(
    controller: controller,
    maxLines: lines,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  ),
);

class _SkillSearch extends SearchDelegate<int?> {
  final List<dynamic> skills;
  _SkillSearch(this.skills);
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      onPressed: () => query = '',
      icon: const Icon(Icons.clear_rounded),
    ),
  ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back_rounded),
  );
  @override
  Widget buildResults(BuildContext context) => _results(context);
  @override
  Widget buildSuggestions(BuildContext context) => _results(context);
  Widget _results(BuildContext context) {
    final filtered = skills.where(
      (skill) => skill.name.toLowerCase().contains(query.toLowerCase()),
    );
    return ListView(
      children: filtered
          .map<Widget>(
            (skill) => ListTile(
              title: Text(skill.name),
              onTap: () => close(context, skill.id as int),
            ),
          )
          .toList(),
    );
  }
}
