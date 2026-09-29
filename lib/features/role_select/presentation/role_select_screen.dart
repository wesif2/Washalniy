import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/user_role.dart';
import '../../profiles/presentation/providers/profile_providers.dart';
import 'widgets/role_card.dart';

class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  bool _saving = false;
  String? _error;

  Future<void> _saveRole(UserRole role) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      context.go('/login');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(profileRepositoryProvider)
          .saveRole(userId: user.id, role: role.name);
      ref.invalidate(currentProfileProvider);
      if (mounted) {
        context.go(
          role == UserRole.driver ? '/driver/home' : '/passenger/home',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not save your choice. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.route_rounded,
                      size: 52,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'How do you want to use Wasselni?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    RoleCard(
                      highlighted: true,
                      icon: Icons.person_rounded,
                      title: 'PASSENGER',
                      subtitle: 'Find and book trips',
                      onTap: _saving
                          ? null
                          : () => _saveRole(UserRole.passenger),
                    ),
                    const SizedBox(height: 16),
                    RoleCard(
                      icon: Icons.directions_car_rounded,
                      title: 'DRIVER',
                      subtitle: 'Offer trips and earn',
                      onTap: _saving ? null : () => _saveRole(UserRole.driver),
                    ),
                    if (_saving) ...[
                      const SizedBox(height: 20),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
