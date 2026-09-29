import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../trips/domain/trip.dart';
import '../data/booking_repository.dart';
import 'providers/booking_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late final List<String> _stops = widget.trip.routeStops.isNotEmpty ? widget.trip.routeStops : [widget.trip.from, widget.trip.to];
  late final Map<String, String> _stopIdByName = {
    for (var i = 0; i < _stops.length; i++)
      _stops[i]: widget.trip.routeStopIds.isNotEmpty && i < widget.trip.routeStopIds.length
          ? widget.trip.routeStopIds[i]
          : _stops[i],
  };
  String? _pickup;
  String? _dropoff;
  int _seats = 1;
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (_stops.isNotEmpty) {
      _pickup = _stops.first;
    }
    if (_stops.length > 1) {
      _dropoff = _stops.last;
    }
  }

  Future<void> _submitBooking() async {
    if (_pickup == null || _dropoff == null || _pickup == _dropoff) {
      setState(() => _errorText = 'اختر نقطة انطلاق ومكان وصول صالحين.');
      return;
    }

    if (_seats <= 0) {
      setState(() => _errorText = 'يجب اختيار عدد مقاعد أكبر من صفر.');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final pickupStopName = _pickup ?? _stops.first;
      final dropoffStopName = _dropoff ?? _stops.last;
      final pickupStopId = _stopIdByName[pickupStopName] ?? pickupStopName;
      final dropoffStopId = _stopIdByName[dropoffStopName] ?? dropoffStopName;
      final booking = await ref.read(bookingRepositoryProvider).createBooking(
        tripId: widget.trip.id,
        pickupStopId: pickupStopId,
        dropoffStopId: dropoffStopId,
        seats: _seats,
      );
      if (!mounted) return;
      ref.invalidate(myBookingsProvider);
      context.push('/booking-confirmation', extra: booking);
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
        title: const Text('حجز الرحلة'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.trip.routeSummary, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${widget.trip.time} · ${widget.trip.driverName}', style: const TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _pickup,
                decoration: const InputDecoration(labelText: 'نقطة الانطلاق', border: OutlineInputBorder()),
                items: _stops
                    .map((stop) => DropdownMenuItem(value: stop, child: Text(stop)))
                    .toList(),
                onChanged: (value) => setState(() => _pickup = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _dropoff,
                decoration: const InputDecoration(labelText: 'نقطة الوصول', border: OutlineInputBorder()),
                items: _stops
                    .map((stop) => DropdownMenuItem(value: stop, child: Text(stop)))
                    .toList(),
                onChanged: (value) => setState(() => _dropoff = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _seats,
                decoration: const InputDecoration(labelText: 'عدد المقاعد', border: OutlineInputBorder()),
                items: [1, 2, 3, 4]
                    .map((seat) => DropdownMenuItem(value: seat, child: Text(seat.toString())))
                    .toList(),
                onChanged: (value) => setState(() => _seats = value ?? 1),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(_errorText!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _submitBooking,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('تأكيد الحجز'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
