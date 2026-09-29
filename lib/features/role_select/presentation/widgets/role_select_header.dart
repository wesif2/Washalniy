import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';

class RoleSelectHeader extends StatelessWidget {
  const RoleSelectHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 90, 24, 44),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
      ),
      child: const Column(
        children: [
          AppLogo(),
          SizedBox(height: 20),
          Text(
            'وصّلني',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'مشوارك مع ناس تثق فيهم',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}