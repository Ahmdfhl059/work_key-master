class HomeViewerModel {
  final String type;
  final bool isAuthenticated;
  final String? name;
  final String? avatarUrl;

  HomeViewerModel({
    required this.type,
    required this.isAuthenticated,
    this.name,
    this.avatarUrl,
  });

  factory HomeViewerModel.initial() =>
      HomeViewerModel(type: 'guest', isAuthenticated: false);

  factory HomeViewerModel.fromMap(Map<String, dynamic> map) {
    return HomeViewerModel(
      type: map['type']?.toString() ?? 'guest',
      isAuthenticated: map['is_authenticated'] == true,
      name: map['name']?.toString(),
      avatarUrl: map['avatar_url']?.toString(),
    );
  }
}

class HomeActionLinkModel {
  final String label;
  final String? route;

  HomeActionLinkModel({required this.label, this.route});

  factory HomeActionLinkModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HomeActionLinkModel(label: 'View');
    }
    return HomeActionLinkModel(
      label: map['label']?.toString() ?? 'View',
      route: map['route']?.toString(),
    );
  }
}

class HomeActionTargetModel {
  final String type;
  final String? id;
  final String? value;

  HomeActionTargetModel({required this.type, this.id, this.value});

  factory HomeActionTargetModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HomeActionTargetModel(type: '');
    }
    return HomeActionTargetModel(
      type: map['type']?.toString() ?? '',
      id: map['id']?.toString(),
      value: map['value']?.toString(),
    );
  }
}

class HomeRequiredActionModel {
  final String type;
  final String title;
  final String? subtitle;
  final String? dateTime;
  final HomeActionLinkModel? action;
  final HomeActionTargetModel? target;

  HomeRequiredActionModel({
    required this.type,
    required this.title,
    this.subtitle,
    this.dateTime,
    this.action,
    this.target,
  });

  factory HomeRequiredActionModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HomeRequiredActionModel(type: '', title: '');
    }

    return HomeRequiredActionModel(
      type: map['type']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString(),
      dateTime: map['date_time']?.toString(),
      action: HomeActionLinkModel.fromMap(
        map['action'] is Map ? Map<String, dynamic>.from(map['action']) : null,
      ),
      target: HomeActionTargetModel.fromMap(
        map['target'] is Map ? Map<String, dynamic>.from(map['target']) : null,
      ),
    );
  }

  String get resolvedLabel {
    final targetType = target?.type ?? '';
    switch (targetType) {
      case 'test_assignment':
        return 'Test Details / Start';
      case 'interview':
        return 'Interview Details';
      case 'information_request':
        return 'Information Request';
      case 'cv_review':
        return 'CV Review';
      case 'profile_suggestions':
        return 'Profile Suggestions';
      case 'profile_section':
        return 'Profile Edit';
      default:
        return action?.label ?? title;
    }
  }

  String? get resolvedRoute {
    final targetType = target?.type ?? '';
    final targetId = target?.id;
    switch (targetType) {
      case 'test_assignment':
        return targetId != null ? '/tests/$targetId' : '/tests';
      case 'interview':
        return targetId != null ? '/interviews/$targetId' : '/interviews';
      case 'information_request':
        return targetId != null
            ? '/information-requests/$targetId'
            : '/information-requests';
      case 'cv_review':
        return '/cv/review';
      case 'profile_suggestions':
        return '/profile/suggestions';
      case 'profile_section':
        return '/profile/edit';
      default:
        return action?.route;
    }
  }
}

class HomeProfileCompletenessModel {
  final int percentage;
  final bool isComplete;
  final int missingItemsCount;
  final HomeNextItemModel? nextItem;

  HomeProfileCompletenessModel({
    required this.percentage,
    required this.isComplete,
    required this.missingItemsCount,
    this.nextItem,
  });

  factory HomeProfileCompletenessModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HomeProfileCompletenessModel(
        percentage: 0,
        isComplete: false,
        missingItemsCount: 0,
      );
    }
    return HomeProfileCompletenessModel(
      percentage: int.tryParse(map['percentage']?.toString() ?? '') ?? 0,
      isComplete: map['is_complete'] == true,
      missingItemsCount:
          int.tryParse(map['missing_items_count']?.toString() ?? '') ?? 0,
      nextItem: HomeNextItemModel.fromMap(
        map['next_item'] is Map
            ? Map<String, dynamic>.from(map['next_item'])
            : null,
      ),
    );
  }
}

class HomeNextItemModel {
  final String key;
  final String label;
  final String? route;

  HomeNextItemModel({required this.key, required this.label, this.route});

  factory HomeNextItemModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HomeNextItemModel(key: '', label: '');
    }
    return HomeNextItemModel(
      key: map['key']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      route: map['route']?.toString(),
    );
  }
}

class HomeHeroModel {
  final String title;
  final String description;
  final HomeActionLinkModel? primaryAction;
  final HomeActionLinkModel? secondaryAction;

  HomeHeroModel({
    required this.title,
    required this.description,
    this.primaryAction,
    this.secondaryAction,
  });

  factory HomeHeroModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HomeHeroModel(title: '', description: '');
    }
    return HomeHeroModel(
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      primaryAction: HomeActionLinkModel.fromMap(
        map['primary_action'] is Map
            ? Map<String, dynamic>.from(map['primary_action'])
            : null,
      ),
      secondaryAction: HomeActionLinkModel.fromMap(
        map['secondary_action'] is Map
            ? Map<String, dynamic>.from(map['secondary_action'])
            : null,
      ),
    );
  }
}

class HomeFeatureModel {
  final String key;
  final String title;
  final String description;

  HomeFeatureModel({
    required this.key,
    required this.title,
    required this.description,
  });

  factory HomeFeatureModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return HomeFeatureModel(key: '', title: '', description: '');
    }
    return HomeFeatureModel(
      key: map['key']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }
}

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
    return HomeCompanyModel(
      id: int.tryParse(map['id']?.toString() ?? ''),
      name: map['name']?.toString() ?? '',
      logoUrl: _nullableDisplayValue(map['logo_url'] ?? map['logo']),
      coverUrl: _nullableDisplayValue(
        map['cover_url'] ?? map['cover_image_url'] ?? map['cover'],
      ),
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
  final String? location;
  final String? workMode;
  final String? employmentType;
  final String? publishedAt;
  final int? matchScore;
  final List<String> matchReasons;

  HomeJobModel({
    required this.id,
    required this.title,
    this.companyName,
    this.location,
    this.workMode,
    this.employmentType,
    this.publishedAt,
    this.matchScore,
    this.matchReasons = const [],
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
      location: _nullableDisplayValue(map['location']),
      workMode: _nullableDisplayValue(map['work_mode']),
      employmentType: _nullableDisplayValue(map['employment_type']),
      publishedAt: map['published_at']?.toString(),
      matchScore: matchMap != null
          ? int.tryParse(matchMap['score']?.toString() ?? '')
          : null,
      matchReasons: reasons,
    );
  }

  static String? _nullableDisplayValue(dynamic value) {
    final display = _displayValue(value);
    return display.isEmpty ? null : display;
  }

  /// API enums and recommendation reasons may be either plain strings or
  /// localized objects. Only the human-readable value is exposed to the UI.
  static String _displayValue(dynamic value) {
    if (value == null) return '';
    if (value is String || value is num || value is bool)
      return value.toString();
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

class HomeResponseModel {
  final bool success;
  final String? message;
  final HomeViewerModel? viewer;
  final HomeProfileCompletenessModel? profileCompleteness;
  final HomeRequiredActionModel? requiredAction;
  final HomeHeroModel? hero;
  final List<HomeJobModel> recommendedJobs;
  final List<HomeCompanyModel> featuredCompanies;
  final List<HomeJobModel> latestJobs;
  final List<HomeFeatureModel> appFeatures;
  final bool recommendationsAvailable;

  HomeResponseModel({
    this.success = true,
    this.message,
    this.viewer,
    this.profileCompleteness,
    this.requiredAction,
    this.hero,
    this.recommendedJobs = const [],
    this.featuredCompanies = const [],
    this.latestJobs = const [],
    this.appFeatures = const [],
    this.recommendationsAvailable = true,
  });

  factory HomeResponseModel.initial() => HomeResponseModel();

  factory HomeResponseModel.fromMap(Map<String, dynamic> map) {
    final data = map['data'];
    if (data is! Map) {
      return HomeResponseModel.initial();
    }

    final responseData = Map<String, dynamic>.from(data);
    final viewerMap = responseData['viewer'] is Map
        ? Map<String, dynamic>.from(responseData['viewer'])
        : null;
    final heroMap = responseData['hero'] is Map
        ? Map<String, dynamic>.from(responseData['hero'])
        : null;
    final profileMap = responseData['profile_completeness'] is Map
        ? Map<String, dynamic>.from(responseData['profile_completeness'])
        : null;
    final requiredActionMap = responseData['required_action'] is Map
        ? Map<String, dynamic>.from(responseData['required_action'])
        : null;
    final meta = map['meta'] is Map
        ? Map<String, dynamic>.from(map['meta'])
        : responseData['meta'] is Map
        ? Map<String, dynamic>.from(responseData['meta'])
        : <String, dynamic>{};

    List<HomeJobModel> parseJobs(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map(
              (entry) => HomeJobModel.fromMap(Map<String, dynamic>.from(entry)),
            )
            .toList();
      }
      return [];
    }

    List<HomeCompanyModel> parseCompanies(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map(
              (entry) =>
                  HomeCompanyModel.fromMap(Map<String, dynamic>.from(entry)),
            )
            .toList();
      }
      return [];
    }

    List<HomeFeatureModel> parseFeatures(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map(
              (entry) =>
                  HomeFeatureModel.fromMap(Map<String, dynamic>.from(entry)),
            )
            .toList();
      }
      return [];
    }

    return HomeResponseModel(
      success: map['success'] == true,
      message: map['message']?.toString(),
      viewer: viewerMap != null
          ? HomeViewerModel.fromMap(viewerMap)
          : HomeViewerModel.initial(),
      profileCompleteness: HomeProfileCompletenessModel.fromMap(profileMap),
      requiredAction: requiredActionMap != null
          ? HomeRequiredActionModel.fromMap(requiredActionMap)
          : null,
      hero: heroMap != null ? HomeHeroModel.fromMap(heroMap) : null,
      recommendedJobs: parseJobs(responseData['recommended_jobs']),
      featuredCompanies: parseCompanies(responseData['featured_companies']),
      latestJobs: parseJobs(responseData['latest_jobs']),
      appFeatures: parseFeatures(responseData['app_features']),
      recommendationsAvailable: meta['recommendations_available'] != false,
    );
  }

  bool get isGuest =>
      viewer?.type == 'guest' || (viewer?.isAuthenticated ?? false) == false;
  bool get isAuthenticated => viewer?.isAuthenticated ?? false;
}
