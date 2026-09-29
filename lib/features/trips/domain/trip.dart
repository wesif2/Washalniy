class Trip {
  const Trip({
    required this.from,
    required this.to,
    required this.time,
    required this.price,
    required this.seatsLeft,
    required this.driverName,
    required this.carModel,
    required this.rating,
  });

  final String from;
  final String to;
  final String time;
  final int price;
  final int seatsLeft;
  final String driverName;
  final String carModel;
  final double rating;
}
