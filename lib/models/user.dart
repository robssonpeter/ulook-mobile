class User {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String role;
  final String? profilePhotoUrl;

  User({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.role,
    this.profilePhotoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'] ?? 'customer',
      profilePhotoUrl: json['profile_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'profile_photo_url': profilePhotoUrl,
    };
  }
}
