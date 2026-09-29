create or replace function public.create_booking(
  p_trip_id uuid,
  p_passenger_id uuid,
  p_pickup_latitude double precision,
  p_pickup_longitude double precision,
  p_pickup_address text,
  p_pickup_stop_id uuid,
  p_dropoff_latitude double precision,
  p_dropoff_longitude double precision,
  p_dropoff_address text,
  p_dropoff_stop_id uuid,
  p_pickup_sequence integer,
  p_dropoff_sequence integer,
  p_seats integer
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_auth_user uuid := auth.uid();
  v_trip public.trips%rowtype;
  v_vehicle public.vehicles%rowtype;
  v_booking_id uuid;
  v_booking_code text;
  v_pickup_route_sequence integer;
  v_dropoff_route_sequence integer;
  v_segment_start integer;
  v_segment_end integer;
  v_occupied integer;
  v_max_sequence integer;
  v_capacity integer;
  v_profile public.profiles%rowtype;
  v_pickup_stop public.route_stops%rowtype;
  v_dropoff_stop public.route_stops%rowtype;
begin
  if v_auth_user is null then
    raise exception 'Authentication required';
  end if;

  if p_passenger_id is null then
    p_passenger_id := v_auth_user;
  end if;

  if p_passenger_id <> v_auth_user then
    raise exception 'Passengers can only create their own bookings';
  end if;

  select * into v_profile
  from public.profiles
  where id = p_passenger_id;

  if v_profile.id is null then
    raise exception 'Passenger profile not found';
  end if;

  if v_profile.role not in ('passenger', 'admin') then
    raise exception 'Only passengers may create bookings';
  end if;

  select * into v_trip
  from public.trips
  where id = p_trip_id
  for update;

  if v_trip.id is null then
    raise exception 'Trip not found';
  end if;

  if v_trip.status <> 'published' then
    raise exception 'Trip is not available for booking';
  end if;

  if not exists (
    select 1
    from public.routes r
    where r.id = v_trip.route_id
      and r.is_active = true
  ) then
    raise exception 'Trip route is not active';
  end if;

  select * into v_vehicle
  from public.vehicles
  where id = v_trip.vehicle_id;

  if v_vehicle.id is null then
    raise exception 'Vehicle not found';
  end if;

  if v_vehicle.verification_status <> 'verified' then
    raise exception 'Vehicle is not verified';
  end if;

  if p_pickup_stop_id is not null then
    select * into v_pickup_stop
    from public.route_stops
    where id = p_pickup_stop_id;

    if v_pickup_stop.id is null or v_pickup_stop.route_id <> v_trip.route_id then
      raise exception 'Pickup stop does not belong to this trip route';
    end if;

    if p_pickup_sequence is not null
       and p_pickup_sequence <> v_pickup_stop.sequence_order then
      raise exception 'Pickup sequence does not match the selected stop';
    end if;
    v_pickup_route_sequence := v_pickup_stop.sequence_order;
  else
    v_pickup_route_sequence := p_pickup_sequence;
  end if;

  if p_dropoff_stop_id is not null then
    select * into v_dropoff_stop
    from public.route_stops
    where id = p_dropoff_stop_id;

    if v_dropoff_stop.id is null or v_dropoff_stop.route_id <> v_trip.route_id then
      raise exception 'Drop-off stop does not belong to this trip route';
    end if;

    if p_dropoff_sequence is not null
       and p_dropoff_sequence <> v_dropoff_stop.sequence_order then
      raise exception 'Drop-off sequence does not match the selected stop';
    end if;
    v_dropoff_route_sequence := v_dropoff_stop.sequence_order;
  else
    v_dropoff_route_sequence := p_dropoff_sequence;
  end if;

  if v_pickup_route_sequence is null or v_dropoff_route_sequence is null then
    raise exception 'Pickup and drop-off sequence are required';
  end if;

  select max(sequence_order) into v_max_sequence
  from public.route_stops
  where route_id = v_trip.route_id;

  if v_max_sequence is null
     or v_pickup_route_sequence < 1
     or v_dropoff_route_sequence < 1
     or v_pickup_route_sequence > v_max_sequence
     or v_dropoff_route_sequence > v_max_sequence then
    raise exception 'Selected route stops are outside the valid route range';
  end if;

  if v_trip.direction = 'outbound' then
    if v_pickup_route_sequence >= v_dropoff_route_sequence then
      raise exception 'Pickup must be before drop-off on the route';
    end if;
    p_pickup_sequence := v_pickup_route_sequence;
    p_dropoff_sequence := v_dropoff_route_sequence;
    v_segment_start := v_pickup_route_sequence;
    v_segment_end := v_dropoff_route_sequence;
  elsif v_trip.direction = 'reverse' then
    if v_pickup_route_sequence <= v_dropoff_route_sequence then
      raise exception 'Pickup must be before drop-off in the reverse direction';
    end if;
    p_pickup_sequence := v_max_sequence + 1 - v_pickup_route_sequence;
    p_dropoff_sequence := v_max_sequence + 1 - v_dropoff_route_sequence;
    v_segment_start := v_dropoff_route_sequence;
    v_segment_end := v_pickup_route_sequence;
  else
    raise exception 'Trip direction is invalid';
  end if;

  v_capacity := least(v_trip.seat_capacity, v_vehicle.seat_capacity);
  if p_seats is null or p_seats <= 0 or p_seats > v_capacity then
    raise exception 'Requested seats are invalid for this trip';
  end if;

  while v_segment_start < v_segment_end loop
    select coalesce(sum(bs.seats), 0)
    into v_occupied
    from public.booking_segments bs
    join public.bookings b on b.id = bs.booking_id
    where bs.trip_id = p_trip_id
      and bs.segment_start_sequence = v_segment_start
      and bs.segment_end_sequence = v_segment_start + 1
      and b.status in ('pending', 'confirmed', 'boarded', 'completed');

    if v_occupied + p_seats > v_capacity then
      raise exception 'This route segment does not have enough available capacity';
    end if;

    v_segment_start := v_segment_start + 1;
  end loop;

  loop
    v_booking_code := 'WS-' || substr(md5(random()::text), 1, 8);
    exit when not exists (
      select 1 from public.bookings where booking_code = v_booking_code
    );
  end loop;

  insert into public.bookings (
    trip_id,
    passenger_id,
    pickup_latitude,
    pickup_longitude,
    pickup_address,
    pickup_stop_id,
    dropoff_latitude,
    dropoff_longitude,
    dropoff_address,
    dropoff_stop_id,
    pickup_sequence,
    dropoff_sequence,
    seats,
    status,
    booking_code,
    payment_method,
    payment_status
  )
  values (
    p_trip_id,
    p_passenger_id,
    p_pickup_latitude,
    p_pickup_longitude,
    p_pickup_address,
    p_pickup_stop_id,
    p_dropoff_latitude,
    p_dropoff_longitude,
    p_dropoff_address,
    p_dropoff_stop_id,
    p_pickup_sequence,
    p_dropoff_sequence,
    p_seats,
    'confirmed',
    v_booking_code,
    'cash',
    'pending'
  )
  returning id into v_booking_id;

  v_segment_start := least(v_pickup_route_sequence, v_dropoff_route_sequence);
  v_segment_end := greatest(v_pickup_route_sequence, v_dropoff_route_sequence);
  while v_segment_start < v_segment_end loop
    insert into public.booking_segments (
      booking_id,
      trip_id,
      segment_start_sequence,
      segment_end_sequence,
      seats
    )
    values (
      v_booking_id,
      p_trip_id,
      v_segment_start,
      v_segment_start + 1,
      p_seats
    );
    v_segment_start := v_segment_start + 1;
  end loop;

  return v_booking_id;
end;
$$;