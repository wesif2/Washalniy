create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(new.email, '@', 1)),
    new.email,
    'passenger'
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  email text,
  avatar_url text,
  role text not null default 'passenger' check (role in ('passenger', 'driver', 'admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists profiles_role_idx on public.profiles(role);

create table if not exists public.drivers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  verification_status text not null default 'pending' check (verification_status in ('pending', 'verified', 'rejected', 'suspended')),
  national_id text,
  rejection_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists drivers_verification_status_idx on public.drivers(verification_status);

create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.drivers(id) on delete cascade,
  make text not null,
  model text not null,
  color text,
  plate_number text not null unique,
  seat_capacity integer not null check (seat_capacity > 0),
  verification_status text not null default 'pending' check (verification_status in ('pending', 'verified', 'rejected')),
  rejection_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists vehicles_driver_id_idx on public.vehicles(driver_id);
create index if not exists vehicles_verification_status_idx on public.vehicles(verification_status);

create table if not exists public.routes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_by uuid not null references public.profiles(id) on delete restrict,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists routes_created_by_idx on public.routes(created_by);
create index if not exists routes_is_active_idx on public.routes(is_active);

create table if not exists public.route_stops (
  id uuid primary key default gen_random_uuid(),
  route_id uuid not null references public.routes(id) on delete cascade,
  name text not null,
  latitude double precision not null,
  longitude double precision not null,
  sequence_order integer not null check (sequence_order > 0),
  created_at timestamptz not null default now(),
  unique (route_id, sequence_order)
);

create index if not exists route_stops_route_id_sequence_idx on public.route_stops(route_id, sequence_order);

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.drivers(id) on delete restrict,
  vehicle_id uuid not null references public.vehicles(id) on delete restrict,
  route_id uuid not null references public.routes(id) on delete restrict,
  direction text not null check (direction in ('outbound', 'reverse')),
  departure_time timestamptz not null,
  estimated_arrival_time timestamptz,
  seat_capacity integer not null check (seat_capacity > 0),
  price numeric(10,2) not null check (price > 0),
  status text not null default 'draft' check (status in ('draft', 'published', 'boarding', 'started', 'completed', 'cancelled')),
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists trips_driver_id_idx on public.trips(driver_id);
create index if not exists trips_route_id_idx on public.trips(route_id);
create index if not exists trips_status_idx on public.trips(status);
create index if not exists trips_departure_time_idx on public.trips(departure_time);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  passenger_id uuid not null references public.profiles(id) on delete restrict,
  pickup_latitude double precision,
  pickup_longitude double precision,
  pickup_address text,
  pickup_stop_id uuid references public.route_stops(id),
  dropoff_latitude double precision,
  dropoff_longitude double precision,
  dropoff_address text,
  dropoff_stop_id uuid references public.route_stops(id),
  pickup_sequence integer,
  dropoff_sequence integer,
  seats integer not null check (seats > 0),
  status text not null default 'pending' check (status in ('pending', 'confirmed', 'boarded', 'completed', 'cancelled', 'no_show')),
  booking_code text not null unique,
  payment_method text not null default 'cash' check (payment_method = 'cash'),
  payment_status text not null default 'pending' check (payment_status in ('pending', 'paid', 'failed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (pickup_sequence is null or pickup_sequence > 0),
  check (dropoff_sequence is null or dropoff_sequence > 0),
  check (pickup_sequence is null or dropoff_sequence is null or pickup_sequence < dropoff_sequence)
);

create index if not exists bookings_trip_id_idx on public.bookings(trip_id);
create index if not exists bookings_passenger_id_idx on public.bookings(passenger_id);
create index if not exists bookings_status_idx on public.bookings(status);

create table if not exists public.booking_segments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  trip_id uuid not null references public.trips(id) on delete cascade,
  segment_start_sequence integer not null check (segment_start_sequence > 0),
  segment_end_sequence integer not null check (segment_end_sequence > segment_start_sequence),
  seats integer not null check (seats > 0),
  created_at timestamptz not null default now(),
  unique (booking_id, segment_start_sequence, segment_end_sequence)
);

create index if not exists booking_segments_booking_id_idx on public.booking_segments(booking_id);
create index if not exists booking_segments_trip_id_idx on public.booking_segments(trip_id);
create index if not exists booking_segments_trip_occupancy_idx on public.booking_segments(trip_id, segment_start_sequence, segment_end_sequence);

create or replace function public.update_updated_at_columns()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute procedure public.update_updated_at_columns();

create trigger drivers_set_updated_at
before update on public.drivers
for each row execute procedure public.update_updated_at_columns();

create trigger vehicles_set_updated_at
before update on public.vehicles
for each row execute procedure public.update_updated_at_columns();

create trigger routes_set_updated_at
before update on public.routes
for each row execute procedure public.update_updated_at_columns();

create trigger trips_set_updated_at
before update on public.trips
for each row execute procedure public.update_updated_at_columns();

create trigger bookings_set_updated_at
before update on public.bookings
for each row execute procedure public.update_updated_at_columns();

create or replace function public.user_is_admin(p_user_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.profiles
    where id = p_user_id
      and role = 'admin'
  );
$$;

create or replace function public.user_is_driver(p_user_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.drivers d
    join public.profiles p on p.id = d.user_id
    where p.id = p_user_id
  );
$$;

create or replace function public.create_trip(
  p_driver_id uuid,
  p_vehicle_id uuid,
  p_route_id uuid,
  p_direction text,
  p_departure_time timestamptz,
  p_seat_capacity integer,
  p_price numeric,
  p_status text default 'draft',
  p_notes text default ''
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_driver_record public.drivers%rowtype;
  v_vehicle_record public.vehicles%rowtype;
  v_route_record public.routes%rowtype;
  v_new_trip_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if p_driver_id is null then
    raise exception 'Driver is required';
  end if;

  select * into v_driver_record
  from public.drivers
  where id = p_driver_id
  for update;

  if v_driver_record.id is null then
    raise exception 'Driver not found';
  end if;

  if v_driver_record.user_id <> auth.uid() then
    raise exception 'Only the driver owner can create trips';
  end if;

  if v_driver_record.verification_status <> 'verified' then
    raise exception 'Driver must be verified before creating trips';
  end if;

  select * into v_vehicle_record
  from public.vehicles
  where id = p_vehicle_id
  for update;

  if v_vehicle_record.id is null then
    raise exception 'Vehicle not found';
  end if;

  if v_vehicle_record.driver_id <> p_driver_id then
    raise exception 'Vehicle does not belong to this driver';
  end if;

  if v_vehicle_record.verification_status <> 'verified' then
    raise exception 'Vehicle must be verified before creating trips';
  end if;

  if p_seat_capacity is null or p_seat_capacity <= 0 then
    raise exception 'Trip capacity must be greater than zero';
  end if;

  if p_seat_capacity > v_vehicle_record.seat_capacity then
    raise exception 'Trip capacity cannot exceed the vehicle seat capacity';
  end if;

  if p_price is null or p_price <= 0 then
    raise exception 'Trip price must be greater than zero';
  end if;

  select * into v_route_record
  from public.routes
  where id = p_route_id;

  if v_route_record.id is null then
    raise exception 'Route not found';
  end if;

  if not v_route_record.is_active then
    raise exception 'Route must be active before creating a trip';
  end if;

  if p_direction not in ('outbound', 'reverse') then
    raise exception 'Direction is invalid';
  end if;

  if p_status not in ('draft', 'published', 'boarding', 'started', 'completed', 'cancelled') then
    raise exception 'Trip status is invalid';
  end if;

  insert into public.trips (
    driver_id,
    vehicle_id,
    route_id,
    direction,
    departure_time,
    seat_capacity,
    price,
    status,
    notes
  )
  values (
    p_driver_id,
    p_vehicle_id,
    p_route_id,
    p_direction,
    p_departure_time,
    p_seat_capacity,
    p_price,
    p_status,
    p_notes
  )
  returning id into v_new_trip_id;

  return v_new_trip_id;
end;
$$;

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
  v_segment_start integer;
  v_segment_end integer;
  v_occupied integer;
  v_max_sequence integer;
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

    if v_pickup_stop.id is null then
      raise exception 'Pickup stop not found';
    end if;

    if v_pickup_stop.route_id <> v_trip.route_id then
      raise exception 'Pickup stop does not belong to this trip route';
    end if;

    if p_pickup_sequence is null then
      p_pickup_sequence := v_pickup_stop.sequence_order;
    elsif p_pickup_sequence <> v_pickup_stop.sequence_order then
      raise exception 'Pickup sequence does not match the selected stop';
    end if;
  end if;

  if p_dropoff_stop_id is not null then
    select * into v_dropoff_stop
    from public.route_stops
    where id = p_dropoff_stop_id;

    if v_dropoff_stop.id is null then
      raise exception 'Drop-off stop not found';
    end if;

    if v_dropoff_stop.route_id <> v_trip.route_id then
      raise exception 'Drop-off stop does not belong to this trip route';
    end if;

    if p_dropoff_sequence is null then
      p_dropoff_sequence := v_dropoff_stop.sequence_order;
    elsif p_dropoff_sequence <> v_dropoff_stop.sequence_order then
      raise exception 'Drop-off sequence does not match the selected stop';
    end if;
  end if;

  if p_pickup_sequence is null or p_dropoff_sequence is null then
    raise exception 'Pickup and drop-off sequence are required';
  end if;

  if p_pickup_sequence <= 0 or p_dropoff_sequence <= 0 then
    raise exception 'Route sequence values must be positive';
  end if;

  if p_pickup_sequence >= p_dropoff_sequence then
    raise exception 'Pickup must be before drop-off on the route';
  end if;

  select max(sequence_order) into v_max_sequence
  from public.route_stops
  where route_id = v_trip.route_id;

  if p_pickup_sequence >= v_max_sequence or p_dropoff_sequence > v_max_sequence then
    raise exception 'Selected route stops are outside the valid route range';
  end if;

  if p_seats <= 0 or p_seats > v_vehicle.seat_capacity or p_seats > v_trip.seat_capacity then
    raise exception 'Requested seats are invalid for this trip';
  end if;

  v_segment_start := p_pickup_sequence;
  while v_segment_start < p_dropoff_sequence loop
    v_segment_end := v_segment_start + 1;

    select coalesce(sum(bs.seats), 0)
    into v_occupied
    from public.booking_segments bs
    join public.bookings b on b.id = bs.booking_id
    where bs.trip_id = p_trip_id
      and bs.segment_start_sequence = v_segment_start
      and bs.segment_end_sequence = v_segment_end
      and b.status in ('pending', 'confirmed', 'boarded', 'completed');

    if (v_occupied + p_seats) > v_vehicle.seat_capacity then
      raise exception 'This route segment does not have enough available capacity';
    end if;

    v_segment_start := v_segment_end;
  end loop;

  loop
    v_booking_code := 'WS-' || substr(md5(random()::text), 1, 8);
    exit when not exists (select 1 from public.bookings where booking_code = v_booking_code);
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

  v_segment_start := p_pickup_sequence;
  while v_segment_start < p_dropoff_sequence loop
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

alter table public.profiles enable row level security;
alter table public.drivers enable row level security;
alter table public.vehicles enable row level security;
alter table public.routes enable row level security;
alter table public.route_stops enable row level security;
alter table public.trips enable row level security;
alter table public.bookings enable row level security;
alter table public.booking_segments enable row level security;

create policy "profiles_select_own_or_admin"
on public.profiles
for select
using (
  auth.uid() = id
  or public.user_is_admin(auth.uid())
);

create policy "profiles_insert_own"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "profiles_update_own_or_admin"
on public.profiles
for update
using (
  auth.uid() = id
  or public.user_is_admin(auth.uid())
)
with check (
  auth.uid() = id
  or public.user_is_admin(auth.uid())
);

create policy "drivers_manage_own_or_admin"
on public.drivers
for all
using (
  user_id = auth.uid()
  or public.user_is_admin(auth.uid())
)
with check (
  user_id = auth.uid()
  or public.user_is_admin(auth.uid())
);

create policy "vehicles_manage_own_or_admin"
on public.vehicles
for all
using (
  driver_id in (
    select id
    from public.drivers
    where user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
)
with check (
  driver_id in (
    select id
    from public.drivers
    where user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
);

create policy "routes_read_active"
on public.routes
for select
using (is_active = true or public.user_is_admin(auth.uid()));

create policy "routes_manage_admin"
on public.routes
for all
using (public.user_is_admin(auth.uid()))
with check (public.user_is_admin(auth.uid()));

create policy "route_stops_read_active"
on public.route_stops
for select
using (
  exists (
    select 1
    from public.routes r
    where r.id = route_stops.route_id
      and (r.is_active = true or public.user_is_admin(auth.uid()))
  )
);

create policy "route_stops_manage_admin"
on public.route_stops
for all
using (public.user_is_admin(auth.uid()))
with check (public.user_is_admin(auth.uid()));

create policy "trips_read_published_or_own_or_admin"
on public.trips
for select
using (
  status = 'published'
  or exists (
    select 1
    from public.drivers d
    where d.id = trips.driver_id
      and d.user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
);

create policy "trips_manage_own_or_admin"
on public.trips
for all
using (
  exists (
    select 1
    from public.drivers d
    where d.id = trips.driver_id
      and d.user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
)
with check (
  exists (
    select 1
    from public.drivers d
    where d.id = trips.driver_id
      and d.user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
);

create policy "bookings_read_own_or_trip_driver_or_admin"
on public.bookings
for select
using (
  passenger_id = auth.uid()
  or exists (
    select 1
    from public.trips t
    join public.drivers d on d.id = t.driver_id
    where t.id = bookings.trip_id
      and d.user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
);

create policy "bookings_insert_own_or_admin"
on public.bookings
for insert
with check (
  passenger_id = auth.uid()
  or public.user_is_admin(auth.uid())
);

create policy "bookings_update_own_or_trip_driver_or_admin"
on public.bookings
for update
using (
  passenger_id = auth.uid()
  or exists (
    select 1
    from public.trips t
    join public.drivers d on d.id = t.driver_id
    where t.id = bookings.trip_id
      and d.user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
)
with check (
  passenger_id = auth.uid()
  or exists (
    select 1
    from public.trips t
    join public.drivers d on d.id = t.driver_id
    where t.id = bookings.trip_id
      and d.user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
);

create policy "booking_segments_read_own_or_trip_driver_or_admin"
on public.booking_segments
for select
using (
  exists (
    select 1
    from public.bookings b
    where b.id = booking_segments.booking_id
      and b.passenger_id = auth.uid()
  )
  or exists (
    select 1
    from public.trips t
    join public.drivers d on d.id = t.driver_id
    where t.id = booking_segments.trip_id
      and d.user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
);

create policy "booking_segments_manage_own_or_trip_driver_or_admin"
on public.booking_segments
for all
using (
  exists (
    select 1
    from public.bookings b
    where b.id = booking_segments.booking_id
      and b.passenger_id = auth.uid()
  )
  or exists (
    select 1
    from public.trips t
    join public.drivers d on d.id = t.driver_id
    where t.id = booking_segments.trip_id
      and d.user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
)
with check (
  exists (
    select 1
    from public.bookings b
    where b.id = booking_segments.booking_id
      and b.passenger_id = auth.uid()
  )
  or exists (
    select 1
    from public.trips t
    join public.drivers d on d.id = t.driver_id
    where t.id = booking_segments.trip_id
      and d.user_id = auth.uid()
  )
  or public.user_is_admin(auth.uid())
);

