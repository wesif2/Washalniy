class TripModel {
  const TripModel({
    required this.id,
    required this.driverId,
    required this.vehicleId,
    required this.routeId,
    required this.direction,
    required this.departureTime,
    required this.seatCapacity,
    required this.price,
    required this.status,
    this.estimatedArrivalTime,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String driverId;
  final String vehicleId;
  final String routeId;
  final String direction;
  final DateTime departureTime;
  final int seatCapacity;
  final double price;
  final String status;
  final DateTime? estimatedArrivalTime;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TripModel.fromSupabase(Map<String, dynamic> json) {
    return TripModel(
      id: (json['id'] ?? '').toString(),
      driverId: (json['driver_id'] ?? '').toString(),
      vehicleId: (json['vehicle_id'] ?? '').toString(),
      routeId: (json['route_id'] ?? '').toString(),
      direction: (json['direction'] ?? 'outbound').toString(),
      departureTime: DateTime.tryParse((json['departure_time'] ?? '').toString()) ?? DateTime.now(),
      seatCapacity: (json['seat_capacity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      status: (json['status'] ?? 'draft').toString(),
      estimatedArrivalTime: json['estimated_arrival_time'] == null
          ? null
          : DateTime.tryParse(json['estimated_arrival_time'].toString()),
      notes: json['notes']?.toString() ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }
}
