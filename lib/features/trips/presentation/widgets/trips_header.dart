import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TripsHeader extends StatelessWidget {
  const TripsHeader({super.key, required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'صباح الخير',
                style: TextStyle(color: AppColors.textMuted, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'رحلات $city',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }
}
