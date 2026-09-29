class Driver {
  const Driver({
    required this.id,
    required this.userId,
    this.verificationStatus = 'pending',
    this.nationalId,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String verificationStatus;
  final String? nationalId;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Driver.fromSupabase(Map<String, dynamic> json) {
    return Driver(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      verificationStatus: (json['verification_status'] ?? 'pending').toString(),
      nationalId: json['national_id']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }
}
