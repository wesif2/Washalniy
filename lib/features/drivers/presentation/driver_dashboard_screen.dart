import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../routes/presentation/providers/route_providers.dart';
import '../../vehicles/presentation/providers/vehicle_providers.dart';
import 'providers/driver_providers.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(currentDriverProvider);
    final vehiclesState = ref.watch(myVehiclesProvider);
    final routesState = ref.watch(activeRoutesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة السائق'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              driverState.when(
                data: (driver) {
                  if (driver == null) {
                    return _StatusCard(
                      title: 'لا توجد بيانات سائق',
                      subtitle: 'أكمل التقديم لبدء الرحلات.',
                      actionLabel: 'تقديم الطلب',
                      onAction: () => context.push('/driver-onboarding'),
                    );
                  }

                  final status = driver.verificationStatus;
                  final subtitle = switch (status) {
                    'verified' => 'حسابك تم التحقق منه، ويمكنك الآن إنشاء رحلات.',
                    'pending' => 'يمكنك إنشاء ملفك الشخصي، لكن الرحلات لا يمكن نشرها حتى التحقق.',
                    'rejected' => 'تم رفض الطلب. أعد التقديم بعد مراجعة البيانات.',
                    'suspended' => 'تم إيقاف حسابك مؤقتًا.',
                    _ => 'حالة الحساب غير متاحة.',
                  };

                  return _StatusCard(
                    title: 'حالة السائق: $status',
                    subtitle: subtitle,
                    actionLabel: status == 'verified' ? 'إنشاء رحلة' : 'تحديث البيانات',
                    onAction: () {
                      if (status == 'verified') {
                        context.push('/trips/create');
                      } else {
                        context.push('/driver-onboarding');
                      }
                    },
                  );
                },
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => _StatusCard(
                  title: 'تعذر تحميل حالة السائق',
                  subtitle: 'حاول مرة أخرى.',
                  actionLabel: 'إعادة المحاولة',
                  onAction: () => ref.invalidate(currentDriverProvider),
                ),
              ),
              const SizedBox(height: 16),
              _ActionTile(
                icon: Icons.directions_car_rounded,
                title: 'سياراتي',
                subtitle: 'إدارة المركبات',
                onTap: () => context.push('/vehicles'),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.route_rounded,
                title: 'إنشاء رحلة',
                subtitle: 'استعرض الطرق واختر الاتجاه والوقت',
                onTap: () => context.push('/trips/create'),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.people_alt_rounded,
                title: 'رحلاتي',
                subtitle: 'عرض الحجوزات والركاب',
                onTap: () => context.push('/driver-trips'),
              ),
              const SizedBox(height: 20),
              _SummarySection(
                title: 'المركبات',
                value: vehiclesState.when(
                  data: (vehicles) => vehicles.length.toString(),
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
              ),
              const SizedBox(height: 12),
              _SummarySection(
                title: 'الطرق المتاحة',
                value: routesState.when(
                  data: (routes) => routes.length.toString(),
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.tint,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryDark),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
