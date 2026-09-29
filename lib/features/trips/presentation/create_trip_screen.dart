import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../routes/presentation/providers/route_providers.dart';
import '../../vehicles/presentation/providers/vehicle_providers.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  String? _selectedRouteId;
  String? _selectedVehicleId;
  String _direction = 'outbound';
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _notesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routes = ref.watch(activeRoutesProvider);
    final vehicles = ref.watch(myVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء رحلة'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'مراجعة المسار والساعة قبل النشر',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              routes.when(
                data: (items) {
                  final routeItems = items;
                  return DropdownButtonFormField<String>(
                    value: _selectedRouteId,
                    decoration: const InputDecoration(
                      labelText: 'الطريق',
                      border: OutlineInputBorder(),
                    ),
                    items: routeItems
                        .map((route) => DropdownMenuItem(
                              value: route.id,
                              child: Text(route.name),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRouteId = value),
                  );
                },
                loading: () => const SizedBox(
                  height: 56,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => const Text('تعذر تحميل الطرق'),
              ),
              const SizedBox(height: 12),
              vehicles.when(
                data: (items) {
                  final vehicleItems = items.where((v) => v.verificationStatus == 'verified').toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedVehicleId,
                    decoration: const InputDecoration(
                      labelText: 'المركبة',
                      border: OutlineInputBorder(),
                    ),
                    items: vehicleItems
                        .map((vehicle) => DropdownMenuItem(
                              value: vehicle.id,
                              child: Text('${vehicle.make} ${vehicle.model}'),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedVehicleId = value),
                  );
                },
                loading: () => const SizedBox(
                  height: 56,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => const Text('تعذر تحميل المركبات'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _direction,
                decoration: const InputDecoration(
                  labelText: 'الاتجاه',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'outbound', child: Text('الخروج')),
                  DropdownMenuItem(value: 'reverse', child: Text('العودة')),
                ],
                onChanged: (value) => setState(() => _direction = value ?? 'outbound'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'تاريخ المغادرة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'وقت المغادرة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات اختيارية',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(_errorText!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loading
                    ? null
                    : () {
                        if (_selectedRouteId == null || _selectedVehicleId == null) {
                          setState(() => _errorText = 'اختر الطريق والمركبة أولاً.');
                          return;
                        }
                        context.push('/trips');
                      },
                icon: const Icon(Icons.save_outlined),
                label: const Text('حفظ كمسودة'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _loading ? null : () => setState(() => _errorText = 'النشر الفعلي يحتاج إلى التحقق من السائق والمركبة في قاعدة البيانات.'),
                icon: const Icon(Icons.publish_rounded),
                label: const Text('نشر الرحلة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
