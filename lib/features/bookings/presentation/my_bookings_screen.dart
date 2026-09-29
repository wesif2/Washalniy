import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import 'providers/booking_providers.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        backgroundColor: AppColors.background,
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('تعذر تحميل الحجوزات'),
              TextButton(
                onPressed: () => ref.invalidate(myBookingsProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(
              child: Text('لا توجد حجوزات حتى الآن.'),
            );
          }

          return ListView.builder(
            itemCount: bookings.length,
            padding: const EdgeInsets.all(18),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.confirmation_number_rounded),
                  title: Text(booking.bookingCode),
                  subtitle: Text('الحالة: ${booking.status}\nالمقاعد: ${booking.seats}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
