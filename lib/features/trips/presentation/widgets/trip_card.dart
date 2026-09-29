import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/trip.dart';

class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip, required this.onBook});

  final Trip trip;
  final VoidCallback onBook;

  String get _seatsText =>
      trip.seatsLeft == 1 ? 'مقعد فاضي' : '${trip.seatsLeft} مقاعد فاضية';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${trip.from}  ←  ${trip.to}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _PriceChip(price: trip.price),
            ],
          ),
          const SizedBox(height: 10),
          _MetaRow(time: trip.time, seatsText: _seatsText),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _DriverRow(trip: trip),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onBook,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('احجز مقعد'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$price ج',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.time, required this.seatsText});

  final String time;
  final String seatsText;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: AppColors.textMuted, fontSize: 15);

    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(time, style: style),
        const SizedBox(width: 16),
        const Icon(Icons.event_seat_rounded,
            size: 18, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(seatsText, style: style),
      ],
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.trip});

  final Trip trip;

  String get _initials => trip.driverName.length >= 2
      ? trip.driverName.substring(0, 2)
      : trip.driverName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.tint,
          child: Text(
            _initials,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${trip.driverName} · ${trip.carModel}',
            style: const TextStyle(fontSize: 16, color: AppColors.dark),
          ),
        ),
        const Icon(Icons.star_rounded, size: 20, color: AppColors.primaryDark),
        const SizedBox(width: 4),
        Text(
          '${trip.rating}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}
