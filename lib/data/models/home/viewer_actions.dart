part of '../home_response_model.dart';

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
      avatarUrl: resolveMediaUrl(
        map['avatar_url'] ??
            map['profile_image_url'] ??
            map['profile_photo_url'] ??
            map['avatar'] ??
            map['profile_image'] ??
            map['image_url'] ??
            map['image'],
      ),
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
