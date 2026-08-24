part of '../profile_manage_sheets.dart';

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
      title: Text(
        context.tr(
          item == null ? 'profile.add_education' : 'profile.edit_education',
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(institution, context.tr('profile.institution')),
            _field(degree, context.tr('profile.degree')),
            _field(field, context.tr('profile.field_of_study')),
            _field(start, context.tr('profile.start_date')),
            _field(end, context.tr('profile.end_date')),
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
            if (institution.text.trim().isEmpty) {
              AppSnackBar.error(
                dialogContext,
                context.tr('profile.education_required'),
              );
              return;
            }
            final saved = await context
                .read<ProfileCubit>()
                .saveEducation(item?.id, {
                  'institution': institution.text.trim(),
                  'degree': _nullable(degree.text),
                  'field_of_study': _nullable(field.text),
                  'start_date': _nullable(start.text),
                  'end_date': _nullable(end.text),
                  'description': _nullable(description.text),
                });
            if (saved && dialogContext.mounted) Navigator.pop(dialogContext);
            if (saved && context.mounted) Navigator.pop(context);
          },
          child: Text(context.tr('common.save')),
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

String? _nullable(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
