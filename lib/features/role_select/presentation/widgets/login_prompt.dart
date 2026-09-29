import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LoginPrompt extends StatelessWidget {
  const LoginPrompt({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'عندك حساب؟',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'سجّل دخول',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
