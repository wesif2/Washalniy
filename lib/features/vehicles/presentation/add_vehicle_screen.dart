import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import 'providers/vehicle_providers.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final make = _makeController.text.trim();
    final model = _modelController.text.trim();
    final plate = _plateController.text.trim();
    final seatCount = int.tryParse(_seatsController.text.trim());

    if (make.isEmpty || model.isEmpty || plate.isEmpty || seatCount == null || seatCount <= 0) {
      setState(() => _errorText = 'البيانات غير مكتملة أو عدد المقاعد غير صالح.');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await ref.read(vehicleRepositoryProvider).addVehicle(
        make: make,
        model: model,
        color: _colorController.text.trim(),
        plateNumber: plate,
        seatCapacity: seatCount,
      );
      if (!mounted) return;
      ref.invalidate(myVehiclesProvider);
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorText = 'تعذر إضافة السيارة. حاول مرة أخرى.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة سيارة'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _makeController,
                decoration: const InputDecoration(labelText: 'الماركة', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'الموديل', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'اللون', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _plateController,
                decoration: const InputDecoration(labelText: 'لوحة السيارة', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'سعة المقاعد', border: OutlineInputBorder()),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(_errorText!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('إضافة السيارة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
