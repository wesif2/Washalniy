import 'package:flutter_test/flutter_test.dart';
import 'package:rides_app/features/bookings/domain/booking.dart';

void main() {
  test('booking projection exposes only route and trip display information', () {
    final booking = Booking.fromSupabase({
      'id': 'booking-1',
      'trip_id': 'trip-1',
      'seats': 2,
      'status': 'confirmed',
      'booking_code': 'WS-REALCODE',
      'direction': 'reverse',
      'route_name': 'Minyet El-Nasr to Cairo',
      'route_stops': [
        {'name': 'Cairo', 'sequence_order': 4},
        {'name': 'Minyet El-Nasr', 'sequence_order': 1},
        {'name': 'Benha', 'sequence_order': 3},
        {'name': 'Mit Ghamr', 'sequence_order': 2},
      ],
      'pickup_stop_name': 'Benha',
      'dropoff_stop_name': 'Mit Ghamr',
      'driver_name': 'Development Driver',
      'driver_verification_status': 'verified',
      'vehicle_make': 'Kia',
      'vehicle_model': 'Cerato',
      'vehicle_color': 'white',
      'departure_time': '2026-09-30T08:00:00Z',
      'price': 120.00,
    });

    expect(booking.bookingCode, 'WS-REALCODE');
    expect(booking.displayedRouteStops, [
      'Cairo',
      'Benha',
      'Mit Ghamr',
      'Minyet El-Nasr',
    ]);
    expect(booking.pickupStopName, 'Benha');
    expect(booking.dropoffStopName, 'Mit Ghamr');
    expect(booking.driverName, 'Development Driver');
    expect(booking.vehicleName, 'Kia Cerato');
    expect(booking.price, 120);
  });
}
