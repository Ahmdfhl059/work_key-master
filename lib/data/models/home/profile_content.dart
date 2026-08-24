part of '../home_response_model.dart';

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
