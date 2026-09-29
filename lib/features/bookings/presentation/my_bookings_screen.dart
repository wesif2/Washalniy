import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/booking.dart';
import 'providers/booking_providers.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          backgroundColor: AppColors.background,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load bookings.'),
                TextButton(
                  onPressed: () => ref.invalidate(myBookingsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (bookings) => TabBarView(
            children: [
              _BookingList(
                bookings: bookings
                    .where((booking) => _isUpcoming(booking))
                    .toList(),
              ),
              _BookingList(
                bookings: bookings
                    .where((booking) => !_isUpcoming(booking))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isUpcoming(Booking booking) {
  if (booking.status == 'cancelled' ||
      booking.status == 'completed' ||
      booking.status == 'no_show') {
    return false;
  }
  return booking.departureTime?.isAfter(DateTime.now()) ?? true;
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings});

  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings in this list.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.confirmation_number_rounded),
            title: Text(
              booking.pickupStopName != null && booking.dropoffStopName != null
                  ? '${booking.pickupStopName} → ${booking.dropoffStopName}'
                  : booking.routeSummary,
            ),
            subtitle: Text(
              '${_bookingDate(booking)} · ${booking.seats} seat(s) · ${booking.price} EGP\n${booking.status}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(
              '/passenger/booking/${booking.id}',
              extra: booking,
            ),
          ),
        );
      },
    );
  }
}

String _bookingDate(Booking booking) {
  final departure = booking.departureTime?.toLocal();
  if (departure == null) return 'Date unavailable';
  final hour = departure.hour.toString().padLeft(2, '0');
  final minute = departure.minute.toString().padLeft(2, '0');
  return '${departure.day}/${departure.month}/${departure.year} · $hour:$minute';
}
