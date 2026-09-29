import 'package:flutter_test/flutter_test.dart';
import 'package:rides_app/features/trips/domain/route_segment_availability.dart';

void main() {
  final route = RouteDefinition(
    origin: 'Minyet El-Nasr',
    destination: 'Cairo',
    stops: const [
      RouteStop(name: 'Minyet El-Nasr', latitude: 30.0, longitude: 31.0, order: 0),
      RouteStop(name: 'Mit Ghamr', latitude: 30.5, longitude: 31.3, order: 1),
      RouteStop(name: 'Benha', latitude: 30.7, longitude: 31.2, order: 2),
      RouteStop(name: 'Cairo', latitude: 30.9, longitude: 31.3, order: 3),
    ],
  );

  test('segment occupancy is calculated independently along the route', () {
    final bookings = [
      const TripBooking(
        bookingCode: 'B-100',
        pickupStopIndex: 0,
        dropoffStopIndex: 3,
        seats: 5,
      ),
      const TripBooking(
        bookingCode: 'B-200',
        pickupStopIndex: 1,
        dropoffStopIndex: 2,
        seats: 2,
      ),
    ];

    final occupancy = TripSeatAvailabilityService.occupancyBySegment(
      route: route,
      bookings: bookings,
    );

    expect(occupancy, {
      0: 5,
      1: 7,
      2: 5,
    });
  });

  test('a booking is rejected when any affected segment is full', () {
    final bookings = [
      const TripBooking(
        bookingCode: 'B-100',
        pickupStopIndex: 0,
        dropoffStopIndex: 3,
        seats: 5,
      ),
      const TripBooking(
        bookingCode: 'B-200',
        pickupStopIndex: 1,
        dropoffStopIndex: 2,
        seats: 2,
      ),
    ];

    final canBook = TripSeatAvailabilityService.canBook(
      tripCapacity: 7,
      route: route,
      existingBookings: bookings,
      pickupStopIndex: 0,
      dropoffStopIndex: 3,
      requestedSeats: 2,
    );

    expect(canBook, isFalse);
  });

  test('a mid-route booking is allowed when every affected segment still has capacity', () {
    final bookings = [
      const TripBooking(
        bookingCode: 'B-100',
        pickupStopIndex: 0,
        dropoffStopIndex: 1,
        seats: 3,
      ),
    ];

    final canBook = TripSeatAvailabilityService.canBook(
      tripCapacity: 7,
      route: route,
      existingBookings: bookings,
      pickupStopIndex: 1,
      dropoffStopIndex: 3,
      requestedSeats: 2,
    );

    expect(canBook, isTrue);
  });
}
