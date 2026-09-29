import '../../routes/domain/route_model.dart';
import 'route_segment_availability.dart';

class Trip {
  const Trip({
    this.id = '',
    this.routeId = '',
    this.vehicleId = '',
    this.driverId = '',
    required this.from,
    required this.to,
    required this.time,
    required this.price,
    required this.seatsLeft,
    required this.driverName,
    required this.carModel,
    required this.rating,
    this.routeStops = const [],
    this.routeStopIds = const [],
    this.status = 'published',
    this.direction = 'outbound',
    this.routeName = '',
    this.seatCapacity = 0,
    this.departureDateTime,
    this.driverVerificationStatus = 'pending',
    this.vehicleMake = '',
    this.vehicleModel = '',
    this.vehicleColor,
    this.vehicleSeatCapacity = 0,
    this.notes = '',
    this.segmentAvailableSeats = const {},
  });

  final String id;
  final String routeId;
  final String vehicleId;
  final String driverId;
  final String from;
  final String to;
  final String time;
  final double price;
  final int seatsLeft;
  final String driverName;
  final String carModel;
  final double rating;
  final List<String> routeStops;
  final List<String> routeStopIds;
  final String status;
  final String direction;
  final String routeName;
  final int seatCapacity;
  final DateTime? departureDateTime;
  final String driverVerificationStatus;
  final String vehicleMake;
  final String vehicleModel;
  final String? vehicleColor;
  final int vehicleSeatCapacity;
  final String notes;
  final Map<int, int> segmentAvailableSeats;

  List<String> get displayedRouteStops =>
      direction == 'reverse' ? routeStops.reversed.toList() : routeStops;

  List<String> get displayedRouteStopIds =>
      direction == 'reverse' ? routeStopIds.reversed.toList() : routeStopIds;

  String get routeSummary {
    if (displayedRouteStops.isNotEmpty) {
      return displayedRouteStops.join(' → ');
    }
    return '$from → $to';
  }

  int availableSeatsForDisplayRange(int pickupIndex, int dropoffIndex) {
    return TripSeatAvailabilityService.availableSeatsForRange(
      tripCapacity: seatCapacity,
      stopCount: routeStops.length,
      availableSeatsBySegmentSequence: segmentAvailableSeats,
      pickupStopIndex: pickupIndex,
      dropoffStopIndex: dropoffIndex,
      reverseDirection: direction == 'reverse',
    );
  }

  factory Trip.fromSupabase(Map<String, dynamic> json) {
    String requiredString(Map<String, dynamic> data, String key) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isEmpty) {
        throw FormatException('Missing trip field: $key');
      }
      return value;
    }

    num requiredNumber(Map<String, dynamic> data, String key) {
      final value = data[key];
      final number = value is num
          ? value
          : num.tryParse(value?.toString() ?? '');
      if (number == null) {
        throw FormatException('Invalid trip field: $key');
      }
      return number;
    }

    Map<String, dynamic> mapValue(dynamic value) =>
        value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

    final id = requiredString(json, 'id');
    final routeId = requiredString(json, 'route_id');
    final driverId = requiredString(json, 'driver_id');
    final vehicleId = requiredString(json, 'vehicle_id');
    final direction = requiredString(json, 'direction');
    if (direction != 'outbound' && direction != 'reverse') {
      throw FormatException('Invalid trip direction: $direction');
    }

    final departureTime = DateTime.tryParse(
      requiredString(json, 'departure_time'),
    );
    if (departureTime == null) {
      throw const FormatException('Invalid trip departure time');
    }

    final routeData = mapValue(json['route']);
    if (routeData.isEmpty) {
      throw const FormatException('Trip route is missing');
    }
    final route = RouteModel.fromSupabase(routeData);
    final validStops =
        route.stops
            .where(
              (stop) =>
                  stop.id.isNotEmpty &&
                  stop.name.trim().isNotEmpty &&
                  stop.sequenceOrder > 0,
            )
            .toList()
          ..sort(
            (left, right) => left.sequenceOrder.compareTo(right.sequenceOrder),
          );
    if (route.id != routeId ||
        route.name.trim().isEmpty ||
        validStops.length < 2) {
      throw const FormatException('Trip route or route stops are invalid');
    }

    final vehicle = mapValue(json['vehicle']);
    final driver = mapValue(json['driver']);
    final profile = mapValue(driver['profile']);
    final driverName = (profile['full_name'] ?? profile['email'] ?? 'سائق')
        .toString();
    final vehicleMake = (vehicle['make'] ?? '').toString();
    final vehicleModel = (vehicle['model'] ?? '').toString();
    final vehicleName = [
      vehicleMake,
      vehicleModel,
    ].where((part) => part.trim().isNotEmpty).join(' ');
    final seatCapacity = requiredNumber(json, 'seat_capacity').toInt();
    final price = requiredNumber(json, 'price').toDouble();
    if (seatCapacity <= 0 || price <= 0) {
      throw const FormatException('Trip capacity and price must be positive');
    }

    final names = validStops.map((stop) => stop.name).toList();
    final stopIds = validStops.map((stop) => stop.id).toList();
    final segmentAvailability = <int, int>{};
    final availabilityData = json['segment_availability'];
    if (availabilityData is List) {
      for (final item in availabilityData) {
        if (item is! Map) continue;
        final segment = Map<String, dynamic>.from(item);
        final sequence = (segment['segment_start_sequence'] as num?)?.toInt();
        final available = (segment['available_seats'] as num?)?.toInt();
        if (sequence != null && sequence > 0 && available != null) {
          segmentAvailability[sequence] = available;
        }
      }
    }
    final isReverse = direction == 'reverse';

    return Trip(
      id: id,
      routeId: routeId,
      vehicleId: vehicleId,
      driverId: driverId,
      from: isReverse ? names.last : names.first,
      to: isReverse ? names.first : names.last,
      time: _formatTime(departureTime),
      departureDateTime: departureTime,
      price: price,
      seatsLeft: seatCapacity,
      seatCapacity: seatCapacity,
      driverName: driverName,
      driverVerificationStatus: (driver['verification_status'] ?? 'pending')
          .toString(),
      carModel: vehicleName.isEmpty ? 'سيارة' : vehicleName,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      vehicleColor: vehicle['color']?.toString(),
      vehicleSeatCapacity: (vehicle['seat_capacity'] as num?)?.toInt() ?? 0,
      rating: 0,
      routeName: route.name,
      routeStops: names,
      routeStopIds: stopIds,
      status: (json['status'] ?? 'published').toString(),
      direction: direction,
      notes: json['notes']?.toString() ?? '',
      segmentAvailableSeats: segmentAvailability,
    );
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $suffix';
  }
}
