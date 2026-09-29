create or replace view public.trip_browse
with (security_barrier = true)
as
select
  t.id,
  t.driver_id,
  t.vehicle_id,
  t.route_id,
  t.direction,
  t.departure_time,
  t.estimated_arrival_time,
  t.seat_capacity,
  t.price,
  t.status,
  r.name as route_name,
  stop_data.route_stops,
  coalesce(nullif(btrim(p.full_name), ''), 'Driver') as driver_name,
  d.verification_status as driver_verification_status,
  v.make as vehicle_make,
  v.model as vehicle_model,
  v.color as vehicle_color,
  v.seat_capacity as vehicle_seat_capacity
from public.trips t
join public.routes r on r.id = t.route_id
join public.drivers d on d.id = t.driver_id
join public.profiles p on p.id = d.user_id
join public.vehicles v on v.id = t.vehicle_id
join lateral (
  select
    jsonb_agg(
      jsonb_build_object(
        'id', rs.id,
        'route_id', rs.route_id,
        'name', rs.name,
        'sequence_order', rs.sequence_order
      ) order by rs.sequence_order
    ) as route_stops,
    count(*) as stop_count
  from public.route_stops rs
  where rs.route_id = r.id
) stop_data on stop_data.stop_count >= 2
where t.status = 'published'
  and r.is_active = true
  and d.verification_status = 'verified'
  and v.verification_status = 'verified';

alter view public.trip_browse owner to postgres;
revoke all privileges on table public.trip_browse from public, anon, authenticated;
grant select on table public.trip_browse to anon, authenticated;