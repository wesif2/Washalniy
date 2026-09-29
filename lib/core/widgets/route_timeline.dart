import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RouteTimeline extends StatelessWidget {
  const RouteTimeline({
    super.key,
    required this.stops,
    this.selectedPickupIndex,
    this.selectedDropoffIndex,
    this.disabledThroughIndex,
    this.onStopTap,
  });

  final List<String> stops;
  final int? selectedPickupIndex;
  final int? selectedDropoffIndex;
  final int? disabledThroughIndex;
  final ValueChanged<int>? onStopTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < stops.length; index++) ...[
          _StopRow(
            name: stops[index],
            isFirst: index == 0,
            isLast: index == stops.length - 1,
            selectedPickup: selectedPickupIndex == index,
            selectedDropoff: selectedDropoffIndex == index,
            disabled:
                disabledThroughIndex != null && index <= disabledThroughIndex!,
            onTap: onStopTap == null ? null : () => onStopTap!(index),
          ),
          if (index < stops.length - 1)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 11),
              child: Container(width: 2, height: 24, color: AppColors.border),
            ),
        ],
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.name,
    required this.isFirst,
    required this.isLast,
    required this.selectedPickup,
    required this.selectedDropoff,
    required this.disabled,
    required this.onTap,
  });

  final String name;
  final bool isFirst;
  final bool isLast;
  final bool selectedPickup;
  final bool selectedDropoff;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedPickup || selectedDropoff;
    final color = disabled
        ? AppColors.textMuted
        : selected
        ? AppColors.primaryDark
        : AppColors.dark;
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primaryDark : Colors.white,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                selectedPickup
                    ? Icons.trip_origin_rounded
                    : selectedDropoff || isLast
                    ? Icons.location_on_rounded
                    : isFirst
                    ? Icons.trip_origin_rounded
                    : Icons.circle,
                size: selected ? 13 : 8,
                color: selected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (selectedPickup)
              const Text(
                'PICKUP',
                style: TextStyle(color: AppColors.primaryDark),
              ),
            if (selectedDropoff)
              const Text(
                'DROP-OFF',
                style: TextStyle(color: AppColors.primaryDark),
              ),
          ],
        ),
      ),
    );
  }
}
