class Booking {
  const Booking({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.seats,
    required this.status,
    required this.bookingCode,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupAddress,
    this.pickupStopId,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.dropoffAddress,
    this.dropoffStopId,
    this.pickupSequence,
    this.dropoffSequence,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tripId;
  final String passengerId;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String? pickupAddress;
  final String? pickupStopId;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String? dropoffAddress;
  final String? dropoffStopId;
  final int? pickupSequence;
  final int? dropoffSequence;
  final int seats;
  final String status;
  final String bookingCode;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Booking.fromSupabase(Map<String, dynamic> json) {
    return Booking(
      id: (json['id'] ?? '').toString(),
      tripId: (json['trip_id'] ?? '').toString(),
      passengerId: (json['passenger_id'] ?? '').toString(),
      pickupLatitude: (json['pickup_latitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num?)?.toDouble(),
      pickupAddress: json['pickup_address']?.toString(),
      pickupStopId: json['pickup_stop_id']?.toString(),
      dropoffLatitude: (json['dropoff_latitude'] as num?)?.toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num?)?.toDouble(),
      dropoffAddress: json['dropoff_address']?.toString(),
      dropoffStopId: json['dropoff_stop_id']?.toString(),
      pickupSequence: (json['pickup_sequence'] as num?)?.toInt(),
      dropoffSequence: (json['dropoff_sequence'] as num?)?.toInt(),
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      bookingCode: (json['booking_code'] ?? '').toString(),
      paymentMethod: (json['payment_method'] ?? 'cash').toString(),
      paymentStatus: (json['payment_status'] ?? 'pending').toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }
}
