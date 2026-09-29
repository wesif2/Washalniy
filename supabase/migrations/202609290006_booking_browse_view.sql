create or replace view public.booking_browse
with (security_barrier = true)
as
select
  b.id,
  b.trip_id,
  b.seats,
  b.status,
  b.booking_code,
  b.pickup_stop_id,
  b.pickup_address,
  b.pickup_sequence,
  pickup_stop.name as pickup_stop_name,
  b.dropoff_stop_id,
  b.dropoff_address,
  b.dropoff_sequence,
  dropoff_stop.name as dropoff_stop_name,
  b.payment_method,
  b.payment_status,
  b.created_at,
  t.direction,
  t.departure_time,
  t.price,
  t.seat_capacity,
  r.name as route_name,
  route_data.route_stops,
  coalesce(nullif(btrim(p.full_name), ''), 'Driver') as driver_name,
  d.verification_status as driver_verification_status,
  v.make as vehicle_make,
  v.model as vehicle_model,
  v.color as vehicle_color,
  v.seat_capacity as vehicle_seat_capacity
from public.bookings b
join public.trips t on t.id = b.trip_id
join public.routes r on r.id = t.route_id
join public.drivers d on d.id = t.driver_id
join public.profiles p on p.id = d.user_id
join public.vehicles v on v.id = t.vehicle_id
left join public.route_stops pickup_stop on pickup_stop.id = b.pickup_stop_id
left join public.route_stops dropoff_stop on dropoff_stop.id = b.dropoff_stop_id
join lateral (
  select jsonb_agg(
    jsonb_build_object(
      'id', rs.id,
      'route_id', rs.route_id,
      'name', rs.name,
      'sequence_order', rs.sequence_order
    ) order by rs.sequence_order
  ) as route_stops
  from public.route_stops rs
  where rs.route_id = t.route_id
) route_data on true
where b.passenger_id = auth.uid()
   or exists (
     select 1
     from public.drivers owner_driver
     where owner_driver.id = t.driver_id
       and owner_driver.user_id = auth.uid()
   );

alter view public.booking_browse owner to postgres;
revoke all privileges on table public.booking_browse from public, anon, authenticated;
grant select on table public.booking_browse to authenticated;