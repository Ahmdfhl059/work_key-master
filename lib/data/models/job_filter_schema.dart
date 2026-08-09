class JobFilterSchema {
  final int schemaVersion;
  final List<JobFilterDefinition> filters;
  final List<JobSortOption> sortOptions;

  const JobFilterSchema({
    required this.schemaVersion,
    required this.filters,
    required this.sortOptions,
  });

  factory JobFilterSchema.fromMap(Map<String, dynamic> map) {
    final data = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'])
        : map;
    return JobFilterSchema(
      schemaVersion: int.tryParse('${data['schema_version'] ?? 0}') ?? 0,
      filters: (data['filters'] is List ? data['filters'] as List : const [])
          .whereType<Map>()
          .map(
            (item) =>
                JobFilterDefinition.fromMap(Map<String, dynamic>.from(item)),
          )
          .where((filter) => filter.isSupported)
          .toList(),
      sortOptions:
          (data['sort_options'] is List
                  ? data['sort_options'] as List
                  : const [])
              .whereType<Map>()
              .map(
                (item) =>
                    JobSortOption.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList(),
    );
  }
}

class JobFilterDefinition {
  final String key;
  final String label;
  final String type;
  final String? parameter;
  final Map<String, String> parameters;
  final List<JobFilterOption> options;
  final JobFilterOptionsSource? optionsSource;
  final dynamic defaultValue;
  final bool clearable;
  final Map<String, dynamic> constraints;
  final JobFilterCondition? visibleWhen;

  const JobFilterDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.parameter,
    required this.parameters,
    required this.options,
    this.optionsSource,
    this.defaultValue,
    required this.clearable,
    required this.constraints,
    this.visibleWhen,
  });

  bool get isSupported => const {
    'single_select',
    'boolean',
    'autocomplete',
    'range',
  }.contains(type);

  factory JobFilterDefinition.fromMap(Map<String, dynamic> map) =>
      JobFilterDefinition(
        key: '${map['key'] ?? ''}',
        label: '${map['label'] ?? map['key'] ?? ''}',
        type: '${map['type'] ?? ''}',
        parameter: map['parameter']?.toString(),
        parameters: _stringMap(map['parameters']),
        options: (map['options'] is List ? map['options'] as List : const [])
            .whereType<Map>()
            .map(
              (item) =>
                  JobFilterOption.fromMap(Map<String, dynamic>.from(item)),
            )
            .toList(),
        optionsSource: map['options_source'] is Map
            ? JobFilterOptionsSource.fromMap(
                Map<String, dynamic>.from(map['options_source']),
              )
            : null,
        defaultValue: map['default'],
        clearable: map['clearable'] != false,
        constraints: map['constraints'] is Map
            ? Map<String, dynamic>.from(map['constraints'])
            : const {},
        visibleWhen: map['visible_when'] is Map
            ? JobFilterCondition.fromMap(
                Map<String, dynamic>.from(map['visible_when']),
              )
            : null,
      );
}

class JobFilterOption {
  final dynamic key;
  final String value;
  final Map<String, dynamic> meta;
  const JobFilterOption({
    required this.key,
    required this.value,
    this.meta = const {},
  });
  factory JobFilterOption.fromMap(Map<String, dynamic> map) => JobFilterOption(
    key: map['key'],
    value: '${map['value'] ?? map['label'] ?? ''}',
    meta: map['meta'] is Map
        ? Map<String, dynamic>.from(map['meta'])
        : const {},
  );
}

class JobFilterOptionsSource {
  final String endpoint;
  final String searchParameter;
  final String valueField;
  final String labelField;
  final int minimumSearchLength;
  const JobFilterOptionsSource({
    required this.endpoint,
    required this.searchParameter,
    required this.valueField,
    required this.labelField,
    required this.minimumSearchLength,
  });
  factory JobFilterOptionsSource.fromMap(Map<String, dynamic> map) =>
      JobFilterOptionsSource(
        endpoint: '${map['endpoint'] ?? ''}',
        searchParameter: '${map['search_parameter'] ?? 'search'}',
        valueField: '${map['value_field'] ?? 'id'}',
        labelField: '${map['label_field'] ?? 'name'}',
        minimumSearchLength:
            int.tryParse('${map['minimum_search_length'] ?? 0}') ?? 0,
      );
}

class JobFilterCondition {
  final String parameter;
  final String operatorName;
  const JobFilterCondition({
    required this.parameter,
    required this.operatorName,
  });
  factory JobFilterCondition.fromMap(Map<String, dynamic> map) =>
      JobFilterCondition(
        parameter: '${map['parameter'] ?? ''}',
        operatorName: '${map['operator'] ?? ''}',
      );
  bool isVisible(Map<String, dynamic> values) =>
      operatorName != 'has_value' ||
      (values[parameter] != null && '${values[parameter]}'.isNotEmpty);
}

class JobSortOption {
  final String key;
  final String value;
  final Map<String, String> parameters;
  const JobSortOption({
    required this.key,
    required this.value,
    required this.parameters,
  });
  factory JobSortOption.fromMap(Map<String, dynamic> map) => JobSortOption(
    key: '${map['key'] ?? ''}',
    value: '${map['value'] ?? map['label'] ?? ''}',
    parameters: _stringMap(map['parameters']),
  );
}

Map<String, String> _stringMap(dynamic value) => value is Map
    ? value.map((key, value) => MapEntry('$key', '$value'))
    : <String, String>{};
