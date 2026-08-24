part of '../profile_manage_sheets.dart';

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
        title: Text(
          context.tr(
            item == null ? 'profile.add_experience' : 'profile.edit_experience',
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(title, context.tr('profile.job_title')),
              _field(company, context.tr('profile.company')),
              _field(location, context.tr('profile.location_details')),
              _field(start, context.tr('profile.start_date')),
              if (!current) _field(end, context.tr('profile.end_date')),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: current,
                title: Text(context.tr('profile.currently_work_here')),
                onChanged: (value) =>
                    setDialogState(() => current = value ?? false),
              ),
              _field(description, context.tr('profile.description'), lines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('common.cancel')),
          ),
          FilledButton(
            onPressed: () async {
              if (title.text.trim().isEmpty || company.text.trim().isEmpty) {
                AppSnackBar.error(
                  dialogContext,
                  context.tr('profile.experience_required'),
                );
                return;
              }
              final saved = await context
                  .read<ProfileCubit>()
                  .saveExperience(item?.id, {
                    'title': title.text.trim(),
                    'company_name': company.text.trim(),
                    'location': _nullable(location.text),
                    'start_date': _nullable(start.text),
                    'end_date': current ? null : _nullable(end.text),
                    'is_current': current,
                    'description': _nullable(description.text),
                  });
              if (saved && dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (saved && context.mounted) Navigator.pop(context);
            },
            child: Text(context.tr('common.save')),
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
