import 'route_stop.dart';

class RouteModel {
  const RouteModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.isActive,
    this.stops = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String createdBy;
  final bool isActive;
  final List<RouteStop> stops;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RouteModel.fromSupabase(Map<String, dynamic> json) {
    final stopsData = json['route_stops'] is List
        ? json['route_stops'] as List
        : const <dynamic>[];

    final stops =
        stopsData
            .map(
              (item) => RouteStop.fromSupabase(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList()
          ..sort(
            (left, right) => left.sequenceOrder.compareTo(right.sequenceOrder),
          );

    return RouteModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      createdBy: (json['created_by'] ?? '').toString(),
      isActive: json['is_active'] as bool? ?? true,
      stops: stops,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }
}
