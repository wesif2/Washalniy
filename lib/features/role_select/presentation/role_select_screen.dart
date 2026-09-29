import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../trips/presentation/trips_screen.dart';
import '../domain/user_role.dart';
import 'widgets/login_prompt.dart';
import 'widgets/role_card.dart';
import 'widgets/role_select_header.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _onRoleSelected(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.passenger:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TripsScreen()),
        );
      case UserRole.driver:
        // TODO: driver flow
        break;
    }
  }

  void _onLoginTap(BuildContext context) {
    // TODO: login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const RoleSelectHeader(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'هتكمل إزاي؟',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RoleCard(
                      highlighted: true,
                      icon: Icons.drive_eta_rounded,
                      title: 'أنا سائق',
                      subtitle: 'انزل رحلتك واستقبل حجوزات',
                      onTap: () => _onRoleSelected(context, UserRole.driver),
                    ),
                    const SizedBox(height: 16),
                    RoleCard(
                      icon: Icons.airline_seat_recline_normal_rounded,
                      title: 'أنا راكب',
                      subtitle: 'دوّر على رحلة واحجز مقعدك',
                      onTap: () => _onRoleSelected(context, UserRole.passenger),
                    ),
                    const Spacer(),
                    Center(
                      child: LoginPrompt(onTap: () => _onLoginTap(context)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}