class RouteStop {
  const RouteStop({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  final String name;
  final double latitude;
  final double longitude;
  final int order;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteStop &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          order == other.order;

  @override
  int get hashCode => Object.hash(name, latitude, longitude, order);
}

class RouteDefinition {
  const RouteDefinition({
    required this.origin,
    required this.destination,
    required this.stops,
  });

  final String origin;
  final String destination;
  final List<RouteStop> stops;

  List<RouteSegment> get segments {
    if (stops.length < 2) {
      return const [];
    }

    final segments = <RouteSegment>[];
    for (var i = 0; i < stops.length - 1; i++) {
      segments.add(
        RouteSegment(
          fromStop: stops[i],
          toStop: stops[i + 1],
          fromIndex: i,
          toIndex: i + 1,
          order: i,
        ),
      );
    }
    return segments;
  }
}

class RouteSegment {
  const RouteSegment({
    required this.fromStop,
    required this.toStop,
    required this.fromIndex,
    required this.toIndex,
    required this.order,
  });

  final RouteStop fromStop;
  final RouteStop toStop;
  final int fromIndex;
  final int toIndex;
  final int order;
}

class TripBooking {
  const TripBooking({
    required this.bookingCode,
    required this.pickupStopIndex,
    required this.dropoffStopIndex,
    required this.seats,
  });

  final String bookingCode;
  final int pickupStopIndex;
  final int dropoffStopIndex;
  final int seats;

  bool get isValidRange => pickupStopIndex < dropoffStopIndex;
}

class TripSeatAvailabilityService {
  const TripSeatAvailabilityService._();

  static Map<int, int> occupancyBySegment({
    required RouteDefinition route,
    required List<TripBooking> bookings,
  }) {
    final occupancy = <int, int>{};

    for (var i = 0; i < route.segments.length; i++) {
      occupancy[i] = 0;
    }

    for (final booking in bookings) {
      if (!booking.isValidRange) {
        continue;
      }

      final affectedSegments = _affectedSegmentIndexes(
        pickupStopIndex: booking.pickupStopIndex,
        dropoffStopIndex: booking.dropoffStopIndex,
      );

      for (final segmentIndex in affectedSegments) {
        occupancy[segmentIndex] = (occupancy[segmentIndex] ?? 0) + booking.seats;
      }
    }

    return occupancy;
  }

  static bool canBook({
    required int tripCapacity,
    required RouteDefinition route,
    required List<TripBooking> existingBookings,
    required int pickupStopIndex,
    required int dropoffStopIndex,
    required int requestedSeats,
  }) {
    if (pickupStopIndex < 0 || dropoffStopIndex <= pickupStopIndex) {
      return false;
    }
    if (pickupStopIndex >= route.stops.length || dropoffStopIndex > route.stops.length) {
      return false;
    }
    if (requestedSeats <= 0 || requestedSeats > tripCapacity) {
      return false;
    }

    final occupancy = occupancyBySegment(
      route: route,
      bookings: existingBookings,
    );

    for (final segmentIndex in _affectedSegmentIndexes(
      pickupStopIndex: pickupStopIndex,
      dropoffStopIndex: dropoffStopIndex,
    )) {
      final currentOccupancy = occupancy[segmentIndex] ?? 0;
      if (currentOccupancy + requestedSeats > tripCapacity) {
        return false;
      }
    }

    return true;
  }

  static Set<int> _affectedSegmentIndexes({
    required int pickupStopIndex,
    required int dropoffStopIndex,
  }) {
    final indexes = <int>{};
    for (var i = pickupStopIndex; i < dropoffStopIndex; i++) {
      indexes.add(i);
    }
    return indexes;
  }
}
