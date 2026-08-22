class CityModel {
  final int id;
  final String code;
  final String name;
  final String countryCode;

  const CityModel({
    required this.id,
    required this.code,
    required this.name,
    required this.countryCode,
  });

  factory CityModel.fromMap(Map<String, dynamic> map) => CityModel(
    id: int.tryParse('${map['id'] ?? ''}') ?? -1,
    code: '${map['code'] ?? ''}',
    name: '${map['name'] ?? ''}',
    countryCode: '${map['country_code'] ?? ''}',
  );
}
