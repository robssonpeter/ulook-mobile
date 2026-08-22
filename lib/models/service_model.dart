class ServiceModel {
  final int id;
  final int? professionalId;
  final String name;
  final String description;
  final double price;
  final int duration;

  ServiceModel({
    required this.id,
    this.professionalId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      professionalId: json['professional_id'] == null
          ? null
          : json['professional_id'] is String
              ? int.parse(json['professional_id'])
              : json['professional_id'] as int,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse((json['price'] ?? 0).toString()),
      duration: json['duration'] == null
          ? 0
          : json['duration'] is String
              ? int.parse(json['duration'])
              : json['duration'] as int,
    );
  }
}
