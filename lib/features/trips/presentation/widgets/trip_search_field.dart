import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TripSearchField extends StatelessWidget {
  const TripSearchField({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.textMuted),
              SizedBox(width: 12),
              Text(
                'رايح فين؟',
                style: TextStyle(color: AppColors.textMuted, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
