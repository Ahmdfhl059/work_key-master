part of '../home_response_model.dart';

class HomeCompanyModel {
  final int? id;
  final String name;
  final String? logoUrl;
  final String? coverUrl;
  final String? specialty;
  final int openJobsCount;

  HomeCompanyModel({
    this.id,
    required this.name,
    this.logoUrl,
    this.coverUrl,
    this.specialty,
    this.openJobsCount = 0,
  });

  factory HomeCompanyModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HomeCompanyModel(name: '');
    }
    final logoUrl = resolveMediaUrl(
      map['logo_url'] ??
          map['logo'] ??
          map['company_logo_url'] ??
          map['logo_path'] ??
          map['company_logo'] ??
          (map['media'] is Map ? (map['media'] as Map)['logo'] : null),
    );
    final coverUrl = resolveMediaUrl(
      map['image_url'] ??
          map['image'] ??
          map['cover_url'] ??
          map['cover_image_url'] ??
          map['cover_image'] ??
          map['banner_url'] ??
          map['cover'] ??
          map['company_image_url'] ??
          map['banner'] ??
          (map['media'] is Map ? (map['media'] as Map)['cover'] : null),
    );
    if (kDebugMode) {
      debugPrint(
        '[Featured company] name=${map['name'] ?? ''} | '
        'website=${map['website'] ?? 'null'} | '
        'logo_url=${logoUrl ?? 'null'} | cover_image_url=${coverUrl ?? 'null'}',
      );
    }
    return HomeCompanyModel(
      id: int.tryParse(map['id']?.toString() ?? ''),
      name: map['name']?.toString() ?? '',
      logoUrl: logoUrl,
      coverUrl: coverUrl,
      specialty: _nullableDisplayValue(
        map['specialty'] ?? map['industry'] ?? map['field'],
      ),
      openJobsCount:
          int.tryParse(
            '${map['open_jobs_count'] ?? map['jobs_count'] ?? map['active_jobs_count'] ?? 0}',
          ) ??
          0,
    );
  }

  static String? _nullableDisplayValue(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
  }
}

class HomeJobModel {
  final int id;
  final String title;
  final String? companyName;
  final String? companyLogoUrl;
  final String? location;
  final String? workMode;
  final String? employmentType;
  final String? publishedAt;
  final num? matchScore;
  final List<String> matchReasons;
  bool hasApplied;
  String applicationStatus;
  final bool isNew;
  final bool isExpired;

  HomeJobModel({
    required this.id,
    required this.title,
    this.companyName,
    this.companyLogoUrl,
    this.location,
    this.workMode,
    this.employmentType,
    this.publishedAt,
    this.matchScore,
    this.matchReasons = const [],
    this.hasApplied = false,
    this.applicationStatus = '',
    this.isNew = false,
    this.isExpired = false,
  });

  factory HomeJobModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HomeJobModel(id: -1, title: '');
    }

    final companyMap = map['company'] is Map
        ? Map<String, dynamic>.from(map['company'])
        : null;
    final matchMap = map['match'] is Map
        ? Map<String, dynamic>.from(map['match'])
        : null;
    final viewerApplication = map['viewer_application'] is Map
        ? Map<String, dynamic>.from(map['viewer_application'])
        : null;
    final reasons = matchMap != null && matchMap['reasons'] is List
        ? (matchMap['reasons'] as List)
              .map(_displayValue)
              .where((reason) => reason.isNotEmpty)
              .toList()
        : <String>[];

    return HomeJobModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? -1,
      title: _displayValue(map['title']),
      companyName: companyMap != null
          ? _displayValue(companyMap['name'])
          : _nullableDisplayValue(map['company']),
      companyLogoUrl: resolveMediaUrl(
        companyMap?['logo_url'] ?? companyMap?['logo'],
      ),
      location: _nullableDisplayValue(map['location']),
      workMode: _nullableDisplayValue(map['work_mode']),
      employmentType: _nullableDisplayValue(map['employment_type']),
      publishedAt: map['published_at']?.toString(),
      matchScore: matchMap != null
          ? num.tryParse(matchMap['score']?.toString() ?? '')
          : null,
      matchReasons: reasons,
      hasApplied: viewerApplication != null || map['has_applied'] == true,
      applicationStatus: _displayValue(viewerApplication?['status']),
      isNew: map['is_new'] == true || _publishedRecently(map['published_at']),
      isExpired:
          map['is_application_deadline_passed'] == true ||
          map['viewer_can_apply'] == false && viewerApplication == null,
    );
  }

  static String? _nullableDisplayValue(dynamic value) {
    final display = _displayValue(value);
    return display.isEmpty ? null : display;
  }

  static bool _publishedRecently(dynamic raw) {
    final date = DateTime.tryParse('${raw ?? ''}')?.toLocal();
    if (date == null) return false;
    final age = DateTime.now().difference(date);
    return !age.isNegative && age <= const Duration(days: 3);
  }

  /// API enums and recommendation reasons may be either plain strings or
  /// localized objects. Only the human-readable value is exposed to the UI.
  static String _displayValue(dynamic value) {
    if (value == null) return '';
    if (value is String || value is num || value is bool) {
      return value.toString();
    }
    if (value is Map) {
      const preferredKeys = [
        'label',
        'message',
        'reason',
        'name',
        'title',
        'value',
        'result',
      ];
      for (final key in preferredKeys) {
        if (value[key] != null) {
          final display = _displayValue(value[key]);
          if (display.isNotEmpty) return display;
        }
      }
      return '';
    }
    if (value is List) {
      return value
          .map(_displayValue)
          .where((item) => item.isNotEmpty)
          .join(' • ');
    }
    return '';
  }
}
