import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/booking.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الحجز'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                '✓ Booking Confirmed',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Booking Code: ${booking.bookingCode}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Route: ${booking.routeSummary}',
                textAlign: TextAlign.center,
              ),
              Text(
                'Departure: ${_confirmationDate(booking)}',
                textAlign: TextAlign.center,
              ),
              Text('Seats: ${booking.seats}', textAlign: TextAlign.center),
              Text('Price: ${booking.price} EGP', textAlign: TextAlign.center),
              Text('Status: ${booking.status}', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(
                  '/passenger/booking/${booking.id}',
                  extra: booking,
                ),
                child: const Text('View Booking'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.go('/passenger/home'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _confirmationDate(Booking booking) {
  final departure = booking.departureTime?.toLocal();
  if (departure == null) return 'Unavailable';
  final hour = departure.hour.toString().padLeft(2, '0');
  final minute = departure.minute.toString().padLeft(2, '0');
  return '${departure.day}/${departure.month}/${departure.year} $hour:$minute';
}
