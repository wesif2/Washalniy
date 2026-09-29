import 'package:flutter/material.dart';

import '../data/mock_trips.dart';
import 'widgets/day_filter_chips.dart';
import 'widgets/trip_card.dart';
import 'widgets/trip_search_field.dart';
import 'widgets/trips_header.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  static const _dayLabels = ['النهارده', 'بكرة', 'الأسبوع ده'];

  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: TripsHeader(city: 'منية النصر'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: TripSearchField(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: DayFilterChips(
                labels: _dayLabels,
                selectedIndex: _selectedDay,
                onSelected: (i) => setState(() => _selectedDay = i),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: mockTrips.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => TripCard(
                  trip: mockTrips[i],
                  onBook: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
