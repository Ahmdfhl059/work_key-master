import 'package:flutter_test/flutter_test.dart';
import 'package:work_key/data/models/job_filter_schema.dart';

void main() {
  group('JobFilterSchema', () {
    final schema = JobFilterSchema.fromMap({
      'data': {
        'schema_version': 1,
        'filters': [
          {
            'key': 'city',
            'label': 'City',
            'type': 'single_select',
            'parameter': 'city_id',
            'options': [
              {'key': 1, 'value': 'Damascus'},
            ],
          },
          {
            'key': 'remote',
            'label': 'Remote',
            'type': 'boolean',
            'parameter': 'include_remote',
            'default': false,
            'visible_when': {'parameter': 'city_id', 'operator': 'has_value'},
          },
          {
            'key': 'salary',
            'label': 'Salary',
            'type': 'range',
            'parameters': {'minimum': 'salary_min', 'maximum': 'salary_max'},
          },
          {
            'key': 'skill',
            'label': 'Skill',
            'type': 'autocomplete',
            'parameter': 'skill',
            'options_source': {
              'endpoint': '/api/v1/skills',
              'search_parameter': 'search',
              'value_field': 'slug',
              'label_field': 'name',
            },
          },
          {'key': 'future', 'type': 'unknown_type'},
        ],
        'sort_options': [
          {
            'key': 'newest',
            'value': 'Newest',
            'parameters': {'sort_by': 'published_at', 'sort_direction': 'desc'},
          },
        ],
      },
    });

    test('parses supported filters and ignores unknown types', () {
      expect(schema.schemaVersion, 1);
      expect(schema.filters.map((filter) => filter.type), [
        'single_select',
        'boolean',
        'range',
        'autocomplete',
      ]);
      expect(schema.filters.first.options.single.value, 'Damascus');
    });

    test('parses range, remote source, and backend sort parameters', () {
      expect(schema.filters[2].parameters['minimum'], 'salary_min');
      expect(schema.filters[3].optionsSource?.endpoint, '/api/v1/skills');
      expect(schema.sortOptions.single.parameters, {
        'sort_by': 'published_at',
        'sort_direction': 'desc',
      });
    });

    test('has_value condition follows the controlling parameter', () {
      final condition = schema.filters[1].visibleWhen!;
      expect(condition.isVisible({}), isFalse);
      expect(condition.isVisible({'city_id': 1}), isTrue);
    });
  });
}
