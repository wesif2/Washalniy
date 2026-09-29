DO $$
DECLARE
  v_dev_email text := 'dev.driver@local.test';
  v_dev_user_id uuid;
  v_profile_id uuid;
  v_driver_id uuid;
  v_vehicle_id uuid;
  v_route_id uuid;
BEGIN
  SELECT id INTO v_dev_user_id
  FROM auth.users
  WHERE email = v_dev_email
  LIMIT 1;

  IF v_dev_user_id IS NULL THEN
    RAISE EXCEPTION 'Development seed requires an existing auth user with email %', v_dev_email;
  END IF;

  INSERT INTO public.profiles (id, full_name, email, role)
  VALUES (v_dev_user_id, 'Development Driver', v_dev_email, 'driver')
  ON CONFLICT (id) DO UPDATE
    SET full_name = COALESCE(public.profiles.full_name, EXCLUDED.full_name),
        email = EXCLUDED.email,
        role = CASE
          WHEN public.profiles.role IN ('passenger', 'driver', 'admin') THEN public.profiles.role
          ELSE EXCLUDED.role
        END;

  SELECT id INTO v_profile_id
  FROM public.profiles
  WHERE id = v_dev_user_id;

  v_route_id := '11111111-1111-4111-8111-111111111111'::uuid;
  v_vehicle_id := '44444444-4444-4444-8444-444444444444'::uuid;

  INSERT INTO public.routes (id, name, created_by, is_active)
  VALUES (v_route_id, 'Minyet El-Nasr → Mit Ghamr → Benha → Cairo', v_profile_id, true)
  ON CONFLICT (id) DO UPDATE
    SET name = EXCLUDED.name,
        created_by = EXCLUDED.created_by,
        is_active = EXCLUDED.is_active;

  INSERT INTO public.route_stops (id, route_id, name, latitude, longitude, sequence_order)
  VALUES
    ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid, v_route_id, 'Minyet El-Nasr', 30.40, 31.10, 1),
    ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid, v_route_id, 'Mit Ghamr', 30.65, 31.25, 2),
    ('cccccccc-cccc-4ccc-8ccc-cccccccccccc'::uuid, v_route_id, 'Benha', 30.77, 31.18, 3),
    ('dddddddd-dddd-4ddd-8ddd-dddddddddddd'::uuid, v_route_id, 'Cairo', 30.82, 31.24, 4)
  ON CONFLICT (route_id, sequence_order) DO UPDATE
    SET name = EXCLUDED.name,
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude;

  INSERT INTO public.drivers (user_id, verification_status, national_id)
  VALUES (v_profile_id, 'verified', 'DEV-DRIVER-NATIONAL-ID')
  ON CONFLICT (user_id) DO UPDATE
    SET verification_status = 'verified',
        national_id = COALESCE(public.drivers.national_id, EXCLUDED.national_id),
        rejection_reason = NULL
  RETURNING id INTO v_driver_id;

  INSERT INTO public.vehicles (id, driver_id, make, model, color, plate_number, seat_capacity, verification_status)
  VALUES (v_vehicle_id, v_driver_id, 'Kia', 'Cerato', 'white', 'ABC-1234', 7, 'verified')
  ON CONFLICT (plate_number) DO UPDATE
    SET driver_id = EXCLUDED.driver_id,
        make = EXCLUDED.make,
        model = EXCLUDED.model,
        color = EXCLUDED.color,
        seat_capacity = EXCLUDED.seat_capacity,
        verification_status = 'verified',
        rejection_reason = NULL;

  INSERT INTO public.trips (id, driver_id, vehicle_id, route_id, direction, departure_time, seat_capacity, price, status, notes)
  VALUES
    ('55555555-5555-4555-8555-555555555555'::uuid, v_driver_id, v_vehicle_id, v_route_id, 'outbound', now() + interval '1 day', 7, 120.00, 'published', 'Development outbound route.'),
    ('66666666-6666-4666-8666-666666666666'::uuid, v_driver_id, v_vehicle_id, v_route_id, 'reverse', now() + interval '2 days', 7, 120.00, 'published', 'Development reverse-direction route.')
  ON CONFLICT (id) DO UPDATE
    SET driver_id = EXCLUDED.driver_id,
        vehicle_id = EXCLUDED.vehicle_id,
        route_id = EXCLUDED.route_id,
        direction = EXCLUDED.direction,
        departure_time = EXCLUDED.departure_time,
        seat_capacity = EXCLUDED.seat_capacity,
        price = EXCLUDED.price,
        status = EXCLUDED.status,
        notes = EXCLUDED.notes;
END $$;
