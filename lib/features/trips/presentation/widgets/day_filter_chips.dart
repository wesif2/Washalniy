import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DayFilterChips extends StatelessWidget {
  const DayFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: _DayChip(
              label: labels[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.dark,
            ),
          ),
        ),
      ),
    );
  }
}
