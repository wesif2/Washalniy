import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final background = highlighted ? AppColors.dark : Colors.white;
    final titleColor = highlighted ? Colors.white : AppColors.dark;
    final subtitleColor = highlighted ? Colors.white70 : AppColors.textMuted;
    final radius = BorderRadius.circular(32);

    return Material(
      color: background,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: highlighted ? AppColors.dark : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              _IconBadge(icon: icon, highlighted: highlighted),
              const SizedBox(width: 16),
              Expanded(
                child: _Texts(
                  title: title,
                  subtitle: subtitle,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: subtitleColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.highlighted});

  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary : AppColors.tint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(
        icon,
        size: 32,
        color: highlighted ? Colors.white : AppColors.primary,
      ),
    );
  }
}

class _Texts extends StatelessWidget {
  const _Texts({
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.subtitleColor,
  });

  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: subtitleColor)),
      ],
    );
  }
}
