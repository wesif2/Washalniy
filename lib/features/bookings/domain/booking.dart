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
    this.direction = 'outbound',
    this.routeName = '',
    this.routeStops = const [],
    this.departureTime,
    this.price = 0,
    this.driverName,
    this.driverVerificationStatus,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.pickupStopName,
    this.dropoffStopName,
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
  final String direction;
  final String routeName;
  final List<String> routeStops;
  final DateTime? departureTime;
  final double price;
  final String? driverName;
  final String? driverVerificationStatus;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? pickupStopName;
  final String? dropoffStopName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  List<String> get displayedRouteStops =>
      direction == 'reverse' ? routeStops.reversed.toList() : routeStops;

  String get routeSummary => displayedRouteStops.isNotEmpty
      ? displayedRouteStops.join(' → ')
      : routeName;

  String get vehicleName => [
    vehicleMake,
    vehicleModel,
  ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');

  factory Booking.fromSupabase(Map<String, dynamic> json) {
    final stopsData = json['route_stops'];
    final stopRows = stopsData is List
      ? stopsData.whereType<Map>().toList()
      : <Map>[];
    stopRows.sort(
      (left, right) =>
        ((left['sequence_order'] as num?)?.toInt() ?? 0).compareTo(
        (right['sequence_order'] as num?)?.toInt() ?? 0,
        ),
    );
    final stops = stopRows
      .map((stop) => (stop['name'] ?? '').toString())
      .where((name) => name.isNotEmpty)
      .toList();

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
      direction: (json['direction'] ?? 'outbound').toString(),
      routeName: (json['route_name'] ?? '').toString(),
      routeStops: stops,
      departureTime: json['departure_time'] == null
          ? null
          : DateTime.tryParse(json['departure_time'].toString()),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      driverName: json['driver_name']?.toString(),
      driverVerificationStatus: json['driver_verification_status']?.toString(),
      vehicleMake: json['vehicle_make']?.toString(),
      vehicleModel: json['vehicle_model']?.toString(),
      vehicleColor: json['vehicle_color']?.toString(),
      pickupStopName: json['pickup_stop_name']?.toString(),
      dropoffStopName: json['dropoff_stop_name']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }
}
