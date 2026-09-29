import 'package:flutter_test/flutter_test.dart';
import 'package:rides_app/features/trips/data/trip_repository.dart';
import 'package:rides_app/features/trips/domain/trip.dart';

void main() {
  group('Trip.fromSupabase', () {
    test('parses trip fields and sorts route stops by sequence_order', () {
      final trip = Trip.fromSupabase(_tripRow());

      expect(trip.id, 'trip-1');
      expect(trip.driverName, 'Development Driver');
      expect(trip.vehicleMake, 'Kia');
      expect(trip.vehicleModel, 'Cerato');
      expect(trip.routeStops, [
        'Minyet El-Nasr',
        'Mit Ghamr',
        'Benha',
        'Cairo',
      ]);
      expect(trip.routeStopIds, ['stop-1', 'stop-2', 'stop-3', 'stop-4']);
    });

    test('displays outbound stops in route order', () {
      final trip = Trip.fromSupabase(_tripRow());

      expect(trip.displayedRouteStops, [
        'Minyet El-Nasr',
        'Mit Ghamr',
        'Benha',
        'Cairo',
      ]);
      expect(trip.routeSummary, 'Minyet El-Nasr → Mit Ghamr → Benha → Cairo');
    });

    test('displays reverse trips in reverse route order', () {
      final trip = Trip.fromSupabase(_tripRow(direction: 'reverse'));

      expect(trip.routeStops, [
        'Minyet El-Nasr',
        'Mit Ghamr',
        'Benha',
        'Cairo',
      ]);
      expect(trip.displayedRouteStops, [
        'Cairo',
        'Benha',
        'Mit Ghamr',
        'Minyet El-Nasr',
      ]);
      expect(trip.displayedRouteStopIds, [
        'stop-4',
        'stop-3',
        'stop-2',
        'stop-1',
      ]);
      expect(trip.routeSummary, 'Cairo → Benha → Mit Ghamr → Minyet El-Nasr');
    });

    test(
      'uses the minimum available seats across the selected direction segment',
      () {
        final row = _tripRow()
          ..['segment_availability'] = [
            {'segment_start_sequence': 1, 'available_seats': 6},
            {'segment_start_sequence': 2, 'available_seats': 3},
            {'segment_start_sequence': 3, 'available_seats': 5},
          ];
        final outbound = Trip.fromSupabase(row);
        final reverse = Trip.fromSupabase({...row, 'direction': 'reverse'});

        expect(outbound.availableSeatsForDisplayRange(1, 3), 3);
        expect(reverse.availableSeatsForDisplayRange(0, 2), 3);
        expect(reverse.availableSeatsForDisplayRange(3, 1), 0);
      },
    );

    test('rejects missing route or route stops', () {
      expect(
        () => Trip.fromSupabase({..._tripRow(), 'route': null}),
        throwsFormatException,
      );
      expect(
        () => Trip.fromSupabase(_tripRow(routeStops: [])),
        throwsFormatException,
      );
    });
  });

  test('repository parsing returns an empty list for no trip rows', () {
    expect(TripRepository.parsePublicBrowseRows([]), isEmpty);
  });

  test('parses the public browse view fields without private profile data', () {
    final row = _tripRow();
    final route = row['route'] as Map<String, dynamic>;
    final driver = row['driver'] as Map<String, dynamic>;
    final profile = driver['profile'] as Map<String, dynamic>;
    final vehicle = row['vehicle'] as Map<String, dynamic>;
    final trip = TripRepository.parsePublicBrowseRows([
      {
        ...row,
        'route_name': route['name'],
        'route_stops': route['route_stops'],
        'driver_name': profile['full_name'],
        'driver_verification_status': driver['verification_status'],
        'vehicle_make': vehicle['make'],
        'vehicle_model': vehicle['model'],
        'vehicle_color': vehicle['color'],
        'vehicle_seat_capacity': vehicle['seat_capacity'],
      },
    ]).single;

    expect(trip.driverName, 'Development Driver');
    expect(trip.driverVerificationStatus, 'verified');
    expect(trip.carModel, 'Kia Cerato');
    expect(trip.routeSummary, 'Minyet El-Nasr → Mit Ghamr → Benha → Cairo');
  });
}

Map<String, dynamic> _tripRow({
  String direction = 'outbound',
  List<Map<String, dynamic>>? routeStops,
}) {
  return {
    'id': 'trip-1',
    'route_id': 'route-1',
    'driver_id': 'driver-1',
    'vehicle_id': 'vehicle-1',
    'direction': direction,
    'departure_time': '2026-09-30T08:30:00Z',
    'seat_capacity': 7,
    'price': 120.50,
    'status': 'published',
    'notes': 'Development trip',
    'route': {
      'id': 'route-1',
      'name': 'Minyet El-Nasr to Cairo',
      'created_by': 'profile-1',
      'is_active': true,
      'route_stops':
          routeStops ??
          [
            _stop('stop-4', 'Cairo', 4),
            _stop('stop-2', 'Mit Ghamr', 2),
            _stop('stop-1', 'Minyet El-Nasr', 1),
            _stop('stop-3', 'Benha', 3),
          ],
    },
    'vehicle': {
      'make': 'Kia',
      'model': 'Cerato',
      'color': 'white',
      'seat_capacity': 7,
    },
    'driver': {
      'verification_status': 'verified',
      'profile': {'full_name': 'Development Driver'},
    },
  };
}

Map<String, dynamic> _stop(String id, String name, int order) => {
  'id': id,
  'route_id': 'route-1',
  'name': name,
  'latitude': 30.0,
  'longitude': 31.0,
  'sequence_order': order,
};
