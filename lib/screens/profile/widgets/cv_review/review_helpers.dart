part of '../../cv_review_screen.dart';

Map<String, dynamic> _draft(Map<String, dynamic> review) {
  final raw =
      review['reviewed_json'] ?? review['draft'] ?? review['final_profile'];
  return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
}

List<Map<String, dynamic>> _suggestions(Map<String, dynamic> review) {
  final raw = review['suggestions'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<Map<String, dynamic>> _suggestionsForStep(
  Map<String, dynamic> review,
  int step,
) {
  final expected = switch (step) {
    0 => 'profile',
    1 => 'experience',
    2 => 'education',
    3 => 'skill',
    _ => '',
  };
  return _suggestions(review).where((item) {
    final entity = _localizedKey(item['entity_type']).toLowerCase();
    if (expected == 'skill') return entity == 'skill' || entity == 'skills';
    return entity == expected;
  }).toList();
}

List<int> _pendingSuggestionIds(Map<String, dynamic> review) =>
    _suggestions(review)
        .where((item) => _localizedKey(item['status']) == 'pending')
        .map((item) {
          return int.tryParse('${item['id'] ?? ''}') ?? -1;
        })
        .where((id) => id >= 0)
        .toList();

String _localizedKey(dynamic value) {
  if (value is Map) {
    final nested =
        value['key'] ??
        value['type'] ??
        value['action'] ??
        value['name'] ??
        value['value'];
    return _localizedKey(nested);
  }
  return '${value ?? ''}';
}

@visibleForTesting
bool isCvReviewComplete(Map<String, dynamic> review) {
  final raw = review['comparison_summary'];
  if (raw is! Map) return false;
  if (raw['is_complete'] == true) return true;
  final unresolved = int.tryParse('${raw['unresolved'] ?? ''}');
  return unresolved == 0;
}

@visibleForTesting
bool isCvActionAllowed(Map<String, dynamic> review, String action) {
  final raw = review['allowed_actions'];
  if (raw is! List) return false;
  return raw.map((item) => item.toString()).contains(action);
}

String _localizedLabel(dynamic value, String fallback) {
  if (value is Map) {
    final text = '${value['label'] ?? value['value'] ?? value['key'] ?? ''}'
        .trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  final text = '${value ?? ''}'.trim();
  return text.isEmpty || text == 'null' ? fallback : text;
}

bool _hasDisplayValue(dynamic value) => _displayLines(value).isNotEmpty;

List<String> _displayLines(dynamic value, {BuildContext? context}) {
  if (value == null) return const [];
  if (value is String || value is num || value is bool) {
    final text = value.toString().trim();
    return text.isEmpty || text == 'null' ? const [] : [text];
  }
  if (value is List) {
    return value
        .expand((item) => _displayLines(item, context: context))
        .where((line) => line.isNotEmpty)
        .toList();
  }
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return map.entries.where((entry) => _hasDisplayValue(entry.value)).map((
      entry,
    ) {
      final child = _displayLines(entry.value, context: context).join(', ');
      final rawLabel = _humanize(entry.key);
      final label = context == null ? rawLabel : context.tr(rawLabel);
      return '$label: $child';
    }).toList();
  }
  return const [];
}

String _humanize(String value) {
  final normalized = value.replaceAll('_', ' ').trim().toLowerCase();
  return normalized.isEmpty
      ? normalized
      : '${normalized[0].toUpperCase()}${normalized.substring(1)}';
}
