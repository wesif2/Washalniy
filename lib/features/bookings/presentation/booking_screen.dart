import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/route_timeline.dart';
import '../../trips/domain/trip.dart';
import 'providers/booking_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late final List<String> _stops = widget.trip.displayedRouteStops;
  int? _pickupIndex;
  int? _dropoffIndex;
  int _seats = 1;
  bool _loading = false;
  bool _customPickup = false;
  String? _errorText;

  int get _availableSeats {
    final pickupIndex = _pickupIndex;
    final dropoffIndex = _dropoffIndex;
    if (pickupIndex == null || dropoffIndex == null) return 0;
    return widget.trip.availableSeatsForDisplayRange(pickupIndex, dropoffIndex);
  }

  @override
  void initState() {
    super.initState();
    if (_stops.isNotEmpty) _pickupIndex = 0;
    if (_stops.length > 1) {
      _dropoffIndex = _stops.length - 1;
    }
  }

  Future<void> _submitBooking() async {
    final pickupIndex = _pickupIndex;
    final dropoffIndex = _dropoffIndex;
    if (pickupIndex == null ||
        dropoffIndex == null ||
        dropoffIndex <= pickupIndex) {
      setState(
        () => _errorText = 'Choose a valid pickup and a later drop-off.',
      );
      return;
    }
    if (_customPickup) {
      setState(
        () => _errorText = 'Custom pickup is not available until route location validation is connected.',
      );
      return;
    }
    if (_seats <= 0 || _seats > _availableSeats) {
      setState(
        () => _errorText = 'Not enough seats are available on this segment.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final stopIds = widget.trip.displayedRouteStopIds;
      final pickupStopId = stopIds[pickupIndex];
      final dropoffStopId = stopIds[dropoffIndex];
      final booking = await ref
          .read(bookingRepositoryProvider)
          .createBooking(
            tripId: widget.trip.id,
            pickupStopId: pickupStopId,
            dropoffStopId: dropoffStopId,
            seats: _seats,
          );
      if (!mounted) return;
      ref.invalidate(myBookingsProvider);
      context.push('/passenger/booking-confirmation', extra: booking);
    } catch (error) {
      if (!mounted) return;
      final message = error.toString();
      final friendlyMessage = message.contains('segment')
          ? 'لا توجد مقاعد كافية في هذا الجزء من المسار.'
          : message.contains('Authentication')
          ? 'يجب تسجيل الدخول قبل حجز الرحلة.'
          : message.contains('network') || message.contains('SocketException')
          ? 'تعذر الوصول إلى الخادم. حاول مرة أخرى.'
          : 'تعذر إتمام الحجز في الوقت الحالي.';
      setState(() => _errorText = friendlyMessage);
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
        title: const Text('Your journey'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.trip.routeSummary,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('${widget.trip.time} · ${widget.trip.driverName}'),
            const SizedBox(height: 24),
            const Text(
              'Choose your pickup',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RouteTimeline(
              stops: _stops,
              selectedPickupIndex: _pickupIndex,
              onStopTap: (index) => setState(() {
                _pickupIndex = index;
                _dropoffIndex = null;
                _errorText = null;
              }),
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Route stop')),
                ButtonSegment(value: true, label: Text('Custom pickup')),
              ],
              selected: {_customPickup},
              onSelectionChanged: (values) => setState(() {
                _customPickup = values.first;
                _errorText = null;
              }),
            ),
            if (_customPickup)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Custom pickup requires a route-compatible location service. It is not available yet.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            const SizedBox(height: 20),
            if (_pickupIndex != null && _pickupIndex! < _stops.length - 1) ...[
              const Text(
                'Choose your drop-off',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RouteTimeline(
                stops: _stops,
                selectedPickupIndex: _pickupIndex,
                selectedDropoffIndex: _dropoffIndex,
                disabledThroughIndex: _pickupIndex,
                onStopTap: (index) => setState(() {
                  _dropoffIndex = index;
                  _errorText = null;
                }),
              ),
              const SizedBox(height: 20),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available on this segment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text('$_availableSeats seats'),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Text('Seats')),
                        IconButton(
                          onPressed: _seats > 1
                              ? () => setState(() => _seats--)
                              : null,
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        Text('$_seats'),
                        IconButton(
                          onPressed: _seats < _availableSeats
                              ? () => setState(() => _seats++)
                              : null,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    Text('Price: ${widget.trip.price} EGP'),
                  ],
                ),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _loading || _availableSeats <= 0 || _customPickup
                  ? null
                  : _submitBooking,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
