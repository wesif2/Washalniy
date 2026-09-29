import 'package:flutter/material.dart';

import '../../../core/widgets/route_timeline.dart';
import '../domain/booking.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final stops = booking.displayedRouteStops;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking code: ${booking.bookingCode}'),
                  Text('Status: ${booking.status}'),
                  Text('Trip: ${booking.routeSummary}'),
                  Text('Departure: ${_bookingDate(booking)}'),
                  Text('Seats: ${booking.seats}'),
                  Text('Price: ${booking.price} EGP'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (booking.driverName != null)
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: Text(booking.driverName!),
              subtitle: Text(
                booking.driverVerificationStatus == 'verified'
                    ? 'Verified Driver'
                    : 'Verification: ${booking.driverVerificationStatus ?? 'unknown'}',
              ),
            ),
          if (booking.vehicleName.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.directions_car_outlined),
              title: Text(booking.vehicleName),
              subtitle: Text(booking.vehicleColor ?? ''),
            ),
          const SizedBox(height: 12),
          const Text('ROUTE', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RouteTimeline(stops: stops),
          const SizedBox(height: 16),
          Text(
            'Pickup: ${booking.pickupStopName ?? booking.pickupAddress ?? 'Unavailable'}',
          ),
          Text(
            'Drop-off: ${booking.dropoffStopName ?? booking.dropoffAddress ?? 'Unavailable'}',
          ),
        ],
      ),
    );
  }
}

String _bookingDate(Booking booking) {
  final departure = booking.departureTime?.toLocal();
  if (departure == null) return 'Unavailable';
  final hour = departure.hour.toString().padLeft(2, '0');
  final minute = departure.minute.toString().padLeft(2, '0');
  return '${departure.day}/${departure.month}/${departure.year} $hour:$minute';
}
