part of '../../cv_review_screen.dart';

class _SuggestionEditor extends StatefulWidget {
  final Map<String, dynamic> suggestion;

  const _SuggestionEditor({required this.suggestion});

  @override
  State<_SuggestionEditor> createState() => _SuggestionEditorState();
}

class _SuggestionEditorState extends State<_SuggestionEditor> {
  final _formKey = GlobalKey<FormState>();
  late final String _entity;
  late final List<String> _fields;
  final Map<String, TextEditingController> _controllers = {};
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    _entity = _localizedKey(widget.suggestion['entity_type']).toLowerCase();
    final raw = widget.suggestion['editable_value'];
    final proposed = widget.suggestion['proposed_value'];
    final source = raw is Map && raw.isNotEmpty
        ? Map<String, dynamic>.from(raw)
        : proposed is Map
        ? Map<String, dynamic>.from(proposed)
        : <String, dynamic>{'name': proposed};
    final normalized = _normalizeEditableSource(_entity, source);
    _fields = _editableFields(_entity, normalized);
    _isCurrent = normalized['is_current'] == true;
    for (final field in _fields.where((field) => field != 'is_current')) {
      _controllers[field] = TextEditingController(
        text: '${normalized[field] ?? ''}'.replaceAll('null', '').trim(),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .9,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withValues(alpha: .5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('cv.edit_extracted_title'),
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              context.tr('cv.edit_extracted_hint'),
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ..._fields.where((field) => field != 'is_current').map((
                    field,
                  ) {
                    if (field == 'end_date' && _isCurrent) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: TextFormField(
                        controller: _controllers[field],
                        keyboardType: _keyboardType(field),
                        minLines: _isLongField(field) ? 3 : 1,
                        maxLines: _isLongField(field) ? 6 : 1,
                        textDirection: field.endsWith('_url')
                            ? TextDirection.ltr
                            : null,
                        decoration: InputDecoration(
                          labelText: context.tr(_fieldLabel(field)),
                          hintText: field.contains('date')
                              ? context.tr('cv.date_hint')
                              : null,
                          prefixIcon: Icon(_fieldIcon(field)),
                        ),
                        validator: (value) {
                          if (_isRequired(field) &&
                              (value == null || value.trim().isEmpty)) {
                            return context.tr('cv.field_required');
                          }
                          if (field == 'city_id' &&
                              value?.trim().isNotEmpty == true &&
                              int.tryParse(value!.trim()) == null) {
                            return context.tr('cv.city_id_invalid');
                          }
                          return null;
                        },
                      ),
                    );
                  }),
                  if (_fields.contains('is_current'))
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: SwitchListTile.adaptive(
                        value: _isCurrent,
                        onChanged: (value) => setState(() {
                          _isCurrent = value;
                          if (value) _controllers['end_date']?.clear();
                        }),
                        title: Text(context.tr('profile.currently_work_here')),
                        secondary: const Icon(Icons.work_outline_rounded),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(context.tr('common.cancel')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.check_rounded),
                          label: Text(context.tr('cv.save_and_use')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final result = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      final value = entry.value.text.trim();
      result[entry.key] = entry.key == 'city_id'
          ? int.tryParse(value)
          : value.isEmpty
          ? null
          : value;
    }
    if (_fields.contains('is_current')) {
      result['is_current'] = _isCurrent;
      if (_isCurrent) result['end_date'] = null;
    }
    Navigator.pop(context, result);
  }

  bool _isRequired(String field) =>
      const {'title', 'company_name', 'institution', 'name'}.contains(field);

  bool _isLongField(String field) =>
      const {'summary', 'description'}.contains(field);

  TextInputType _keyboardType(String field) {
    if (field == 'phone') return TextInputType.phone;
    if (field == 'city_id') return TextInputType.number;
    if (field.endsWith('_url')) return TextInputType.url;
    if (_isLongField(field)) return TextInputType.multiline;
    return TextInputType.text;
  }
}

Map<String, dynamic> _normalizeEditableSource(
  String entity,
  Map<String, dynamic> source,
) {
  final result = Map<String, dynamic>.from(source);
  if (entity == 'experience') {
    result['title'] ??= result['job_title'] ?? result['position'];
    result['company_name'] ??= result['company'] ?? result['employer'];
  } else if (entity == 'education') {
    result['institution'] ??= result['school'] ?? result['university'];
    result['field_of_study'] ??= result['field'];
  } else if (entity == 'skill' || entity == 'skills') {
    result['name'] ??= result['skill'];
  }
  return result;
}

List<String> _editableFields(String entity, Map<String, dynamic> source) {
  if (entity == 'profile') {
    return const [
      'phone',
      'summary',
      'location',
      'city_id',
    ].where(source.containsKey).take(1).toList();
  }
  if (entity == 'experience') {
    return const [
      'title',
      'company_name',
      'location',
      'start_date',
      'end_date',
      'is_current',
      'description',
    ];
  }
  if (entity == 'education') {
    return const [
      'institution',
      'degree',
      'field_of_study',
      'start_date',
      'end_date',
      'description',
    ];
  }
  if (entity == 'skill' || entity == 'skills') return const ['name'];
  return const [];
}

bool _isSuggestionEditable(Map<String, dynamic> suggestion) {
  if (suggestion['can_edit'] != true) return false;
  final entity = _localizedKey(suggestion['entity_type']).toLowerCase();
  final proposed = suggestion['proposed_value'];
  final source = proposed is Map
      ? Map<String, dynamic>.from(proposed)
      : <String, dynamic>{'name': proposed};
  return _editableFields(
    entity,
    _normalizeEditableSource(entity, source),
  ).isNotEmpty;
}

String _fieldLabel(String field) => switch (field) {
  'phone' => 'profile.phone',
  'summary' => 'profile.professional_summary',
  'location' => 'profile.location_details',
  'city_id' => 'profile.city',
  'title' => 'profile.job_title',
  'company_name' => 'profile.company',
  'start_date' => 'profile.start_date',
  'end_date' => 'profile.end_date',
  'description' => 'profile.description',
  'institution' => 'profile.institution',
  'degree' => 'profile.degree',
  'field_of_study' => 'profile.field_of_study',
  'name' => 'profile.skills',
  _ => field,
};

IconData _fieldIcon(String field) => switch (field) {
  'phone' => Icons.phone_outlined,
  'summary' => Icons.notes_rounded,
  'location' => Icons.location_on_outlined,
  'city_id' => Icons.location_city_outlined,
  'title' => Icons.badge_outlined,
  'company_name' => Icons.business_outlined,
  'start_date' || 'end_date' => Icons.calendar_month_outlined,
  'description' => Icons.subject_rounded,
  'institution' => Icons.school_outlined,
  'degree' => Icons.workspace_premium_outlined,
  'field_of_study' => Icons.menu_book_outlined,
  'name' => Icons.bolt_rounded,
  _ => Icons.edit_outlined,
};
