class Profile {
  const Profile({
    required this.id,
    this.fullName,
    this.phone,
    this.email,
    this.avatarUrl,
    this.role = 'passenger',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Profile.fromSupabase(Map<String, dynamic> json) {
    return Profile(
      id: (json['id'] ?? '').toString(),
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      role: (json['role'] ?? 'passenger').toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }
}
