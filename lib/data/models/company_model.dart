import '../../utils/media_url.dart';
import 'package:flutter/foundation.dart';

class CompanyModel {
  String? message;
  final int id;
  String name;
  String industry;
  String website;
  String location;
  String description;
  String logo;
  String coverImage;
  String companySize;
  String approvalStatus;
  double rating;
  int reviewsCount;

  CompanyModel({
    this.message,
    required this.id,
    required this.name,
    required this.industry,
    required this.website,
    required this.location,
    required this.description,
    required this.logo,
    this.coverImage = '',
    required this.companySize,
    required this.approvalStatus,
    required this.rating,
    required this.reviewsCount,
  });

  factory CompanyModel.initial() => CompanyModel(
    id: -1,
    name: '',
    message: '',
    industry: '',
    website: '',
    location: '',
    description: '',
    logo: '',
    coverImage: '',
    companySize: '',
    approvalStatus: '',
    rating: 0.0,
    reviewsCount: 0,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'industry': industry,
      'website': website,
      'location': location,
      'description': description,
      'logo': logo,
      'cover_image_url': coverImage,
      'company_size': companySize,
      'approval_status': approvalStatus,
      'rating': rating,
      'reviews_count': reviewsCount,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    final logo = resolveMediaUrl(
      map['logo_url'] ??
          map['logo'] ??
          map['company_logo_url'] ??
          map['logo_path'] ??
          map['company_logo'] ??
          (map['media'] is Map ? (map['media'] as Map)['logo'] : null),
    );
    if (kDebugMode) {
      debugPrint('--- Company media ---');
      debugPrint('Company: ${map['name'] ?? ''}');
      debugPrint('Website: ${map['website'] ?? ''}');
      debugPrint('Logo URL: ${logo ?? ''}');
      debugPrint('Cover URL: ${resolveMediaUrl(map['cover_image_url']) ?? ''}');
    }
    return CompanyModel(
      id: int.tryParse(map['id'].toString()) ?? -1,
      name: map['name']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      industry: map['industry']?.toString() ?? '',
      website: map['website']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      logo: logo ?? '',
      coverImage:
          resolveMediaUrl(
            map['cover_image_url'] ??
                map['cover_url'] ??
                map['cover_image'] ??
                (map['media'] is Map ? (map['media'] as Map)['cover'] : null),
          ) ??
          '',
      companySize: map['company_size']?.toString() ?? '',
      approvalStatus: _displayValue(map['approval_status']),
      rating: double.tryParse(map['rating'].toString()) ?? 0.0,
      reviewsCount: int.tryParse(map['reviews_count'].toString()) ?? 0,
    );
  }

  static String _displayValue(dynamic value) {
    if (value is Map) {
      return '${value['value'] ?? value['label'] ?? value['key'] ?? ''}';
    }
    return '${value ?? ''}';
  }
}
