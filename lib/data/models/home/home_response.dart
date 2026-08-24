part of '../home_response_model.dart';

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
