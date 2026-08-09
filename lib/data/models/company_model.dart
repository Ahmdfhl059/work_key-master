class CompanyModel {
  String? message;
  final int id;
  String name;
  String industry;
  String website;
  String location;
  String description;
  String logo;
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
      'company_size': companySize,
      'approval_status': approvalStatus,
      'rating': rating,
      'reviews_count': reviewsCount,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: int.tryParse(map['id'].toString()) ?? -1,
      name: map['name']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      industry: map['industry']?.toString() ?? '',
      website: map['website']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      logo: map['logo_url']?.toString() ?? map['logo']?.toString() ?? '',
      companySize: map['company_size']?.toString() ?? '',
      approvalStatus: map['approval_status']?.toString() ?? '',
      rating: double.tryParse(map['rating'].toString()) ?? 0.0,
      reviewsCount: int.tryParse(map['reviews_count'].toString()) ?? 0,
    );
  }
}
