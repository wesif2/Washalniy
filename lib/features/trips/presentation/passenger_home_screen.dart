import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../profiles/presentation/providers/profile_providers.dart';
import '../../routes/domain/route_model.dart';
import '../../routes/domain/route_stop.dart';
import '../../routes/presentation/providers/route_providers.dart';

class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  ConsumerState<PassengerHomeScreen> createState() =>
      _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen> {
  String? _routeId;
  String? _pickupStopId;
  String? _dropoffStopId;
  DateTime _departureDate = DateTime.now().add(const Duration(days: 1));
  String? _errorText;

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) setState(() => _departureDate = selected);
  }

  void _search(List<RouteModel> routes) {
    final route = routes.where((item) => item.id == _routeId).firstOrNull;
    final pickupIndex =
        route?.stops.indexWhere((stop) => stop.id == _pickupStopId) ?? -1;
    final dropoffIndex =
        route?.stops.indexWhere((stop) => stop.id == _dropoffStopId) ?? -1;
    if (route == null || pickupIndex < 0 || dropoffIndex <= pickupIndex) {
      setState(
        () => _errorText = 'Choose a route, pickup and a later drop-off.',
      );
      return;
    }

    final pickup = route.stops[pickupIndex];
    final dropoff = route.stops[dropoffIndex];
    final query = {
      'routeId': route.id,
      'from': pickup.name,
      'to': dropoff.name,
      'date': _dateKey(_departureDate),
    };
    context.go(
      Uri(path: '/passenger/trips', queryParameters: query).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).asData?.value;
    final routesAsync = ref.watch(activeRoutesProvider);
    final firstName = profile?.fullName?.trim().split(' ').firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Wasselni')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              'Hello${firstName == null || firstName.isEmpty ? '' : ', $firstName'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 6),
            const Text('Where are you going?'),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: routesAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Column(
                    children: [
                      const Text('Unable to load routes.'),
                      TextButton(
                        onPressed: () => ref.invalidate(activeRoutesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                  data: (routes) => _buildSearchForm(routes),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm(List<RouteModel> routes) {
    final selectedRoute = routes
        .where((route) => route.id == _routeId)
        .firstOrNull;
    final stops = selectedRoute?.stops ?? const <RouteStop>[];
    final pickupIndex = stops.indexWhere((stop) => stop.id == _pickupStopId);
    final dropoffStops = pickupIndex < 0
        ? stops
        : stops.skip(pickupIndex + 1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: routes.any((route) => route.id == _routeId)
              ? _routeId
              : null,
          decoration: const InputDecoration(labelText: 'ROUTE'),
          items: routes
              .map(
                (route) => DropdownMenuItem(
                  value: route.id,
                  child: Text(route.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() {
            _routeId = value;
            _pickupStopId = null;
            _dropoffStopId = null;
            _errorText = null;
          }),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: stops.any((stop) => stop.id == _pickupStopId)
              ? _pickupStopId
              : null,
          decoration: const InputDecoration(labelText: 'FROM'),
          items: stops
              .map(
                (stop) =>
                    DropdownMenuItem(value: stop.id, child: Text(stop.name)),
              )
              .toList(),
          onChanged: (value) => setState(() {
            _pickupStopId = value;
            _dropoffStopId = null;
            _errorText = null;
          }),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: dropoffStops.any((stop) => stop.id == _dropoffStopId)
              ? _dropoffStopId
              : null,
          decoration: const InputDecoration(labelText: 'TO'),
          items: dropoffStops
              .map(
                (stop) =>
                    DropdownMenuItem(value: stop.id, child: Text(stop.name)),
              )
              .toList(),
          onChanged: (value) => setState(() {
            _dropoffStopId = value;
            _errorText = null;
          }),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _chooseDate,
          icon: const Icon(Icons.calendar_today_rounded),
          label: Text('DATE  ${_dateLabel(_departureDate)}'),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(_errorText!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _search(routes),
          icon: const Icon(Icons.search_rounded),
          label: const Text('Search Trips'),
        ),
        if (routes.isEmpty) ...[
          const SizedBox(height: 12),
          const Text('No active routes are available yet.'),
        ],
      ],
    );
  }
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
