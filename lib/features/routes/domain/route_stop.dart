class RouteStop {
  const RouteStop({
    required this.id,
    required this.routeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequenceOrder,
    this.createdAt,
  });

  final String id;
  final String routeId;
  final String name;
  final double latitude;
  final double longitude;
  final int sequenceOrder;
  final DateTime? createdAt;

  factory RouteStop.fromSupabase(Map<String, dynamic> json) {
    return RouteStop(
      id: (json['id'] ?? '').toString(),
      routeId: (json['route_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      sequenceOrder: (json['sequence_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}
