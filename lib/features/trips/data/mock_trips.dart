import '../domain/trip.dart';

const mockTrips = <Trip>[
  Trip(
    from: 'منية النصر',
    to: 'القاهرة',
    time: '7:30 ص',
    price: 120,
    seatsLeft: 3,
    driverName: 'أحمد',
    carModel: 'كيا سيراتو',
    rating: 4.9,
    routeStops: const ['منية النصر', 'ميت غمر', 'بنها', 'القاهرة'],
  ),
  Trip(
    from: 'منية النصر',
    to: 'المنصورة',
    time: '9:00 ص',
    price: 35,
    seatsLeft: 1,
    driverName: 'محمود',
    carModel: 'هيونداي إلنترا',
    rating: 4.8,
    routeStops: const ['منية النصر', 'المنصورة'],
  ),
];
