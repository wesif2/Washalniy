import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/route_timeline.dart';
import '../../drivers/presentation/providers/driver_providers.dart';
import '../../routes/presentation/providers/route_providers.dart';
import '../../trips/presentation/providers/trip_providers.dart';
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
  int _seatCapacity = 1;
  final _notesController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _departure = DateTime.now().add(const Duration(days: 1));
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDepartureDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _departure,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      setState(() {
        _departure = DateTime(
          selected.year,
          selected.month,
          selected.day,
          _departure.hour,
          _departure.minute,
        );
      });
    }
  }

  Future<void> _selectDepartureTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departure),
    );
    if (selected != null) {
      setState(() {
        _departure = DateTime(
          _departure.year,
          _departure.month,
          _departure.day,
          selected.hour,
          selected.minute,
        );
      });
    }
  }

  Future<void> _publishTrip({
    required String driverId,
    required String routeId,
    required String vehicleId,
  }) async {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0 || _departure.isBefore(DateTime.now())) {
      setState(
        () => _errorText = 'Choose a future departure and a valid price.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review trip'),
        content: Text(
          '${_direction == 'outbound' ? 'Outbound' : 'Reverse'} · '
          '${_departure.toLocal()} · $_seatCapacity seats · $price EGP',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Edit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      await ref
          .read(tripRepositoryProvider)
          .createTrip(
            driverId: driverId,
            vehicleId: vehicleId,
            routeId: routeId,
            direction: _direction,
            departureTime: _departure,
            seatCapacity: _seatCapacity,
            price: price,
            notes: _notesController.text.trim(),
          );
      ref.invalidate(myTripsProvider);
      ref.invalidate(publishedTripsProvider);
      if (mounted) context.go('/driver/trips');
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorText = 'Unable to publish this trip. Check your driver and vehicle verification.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routes = ref.watch(activeRoutesProvider);
    final vehicles = ref.watch(myVehiclesProvider);
    final driver = ref.watch(currentDriverProvider);

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
                'Create a trip',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              routes.when(
                data: (items) {
                  final routeItems = items;
                  return DropdownButtonFormField<String>(
                    initialValue:
                        items.any((route) => route.id == _selectedRouteId)
                        ? _selectedRouteId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'الطريق',
                      border: OutlineInputBorder(),
                    ),
                    items: routeItems
                        .map(
                          (route) => DropdownMenuItem(
                            value: route.id,
                            child: Text(route.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedRouteId = value),
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
                  final vehicleItems = items
                      .where((v) => v.verificationStatus == 'verified')
                      .toList();
                  return DropdownButtonFormField<String>(
                    initialValue:
                        vehicleItems.any(
                          (vehicle) => vehicle.id == _selectedVehicleId,
                        )
                        ? _selectedVehicleId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'المركبة',
                      border: OutlineInputBorder(),
                    ),
                    items: vehicleItems
                        .map(
                          (vehicle) => DropdownMenuItem(
                            value: vehicle.id,
                            child: Text('${vehicle.make} ${vehicle.model}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedVehicleId = value;
                      final selectedVehicle = vehicleItems
                          .where((vehicle) => vehicle.id == value)
                          .firstOrNull;
                      if (selectedVehicle != null &&
                          _seatCapacity > selectedVehicle.seatCapacity) {
                        _seatCapacity = selectedVehicle.seatCapacity;
                      }
                    }),
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
                initialValue: _direction,
                decoration: const InputDecoration(
                  labelText: 'Direction',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'outbound',
                    child: Text('Origin to destination'),
                  ),
                  DropdownMenuItem(
                    value: 'reverse',
                    child: Text('Destination to origin'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _direction = value ?? 'outbound'),
              ),
              const SizedBox(height: 12),
              if (routes.asData?.value
                      .where((route) => route.id == _selectedRouteId)
                      .firstOrNull
                  case final route?) ...[
                const SizedBox(height: 12),
                RouteTimeline(
                  stops: _direction == 'reverse'
                      ? route.stops.reversed.map((stop) => stop.name).toList()
                      : route.stops.map((stop) => stop.name).toList(),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _selectDepartureDate,
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(
                  'Departure date: ${_departure.day}/${_departure.month}/${_departure.year}',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _selectDepartureTime,
                icon: const Icon(Icons.schedule_rounded),
                label: Text(
                  'Departure time: ${TimeOfDay.fromDateTime(_departure).format(context)}',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _seatCapacity,
                decoration: const InputDecoration(labelText: 'Available seats'),
                items: List.generate(
                  (vehicles.asData?.value
                              .where(
                                (vehicle) => vehicle.id == _selectedVehicleId,
                              )
                              .firstOrNull
                              ?.seatCapacity ??
                          0)
                      .clamp(0, 9),
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} seats'),
                  ),
                ),
                onChanged: (value) =>
                    setState(() => _seatCapacity = value ?? 1),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Price (EGP)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loading
                    ? null
                    : () {
                        final driverValue = driver.asData?.value;
                        if (_selectedRouteId == null ||
                            _selectedVehicleId == null ||
                            driverValue == null ||
                            driverValue.verificationStatus != 'verified') {
                          setState(
                            () => _errorText = 'A verified driver, route and vehicle are required.',
                          );
                          return;
                        }
                        _publishTrip(
                          driverId: driverValue.id,
                          routeId: _selectedRouteId!,
                          vehicleId: _selectedVehicleId!,
                        );
                      },
                icon: const Icon(Icons.save_outlined),
                label: Text(_loading ? 'Publishing...' : 'Publish trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
