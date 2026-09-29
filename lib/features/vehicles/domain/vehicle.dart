class Vehicle {
  const Vehicle({
    required this.id,
    required this.driverId,
    required this.make,
    required this.model,
    required this.plateNumber,
    required this.seatCapacity,
    this.color,
    this.verificationStatus = 'pending',
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String driverId;
  final String make;
  final String model;
  final String plateNumber;
  final int seatCapacity;
  final String? color;
  final String verificationStatus;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Vehicle.fromSupabase(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] ?? '').toString(),
      driverId: (json['driver_id'] ?? '').toString(),
      make: (json['make'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      plateNumber: (json['plate_number'] ?? '').toString(),
      seatCapacity: (json['seat_capacity'] as num?)?.toInt() ?? 0,
      color: json['color']?.toString(),
      verificationStatus: (json['verification_status'] ?? 'pending').toString(),
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
