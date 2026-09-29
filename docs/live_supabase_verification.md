# Live Supabase verification checklist

The initial schema migration is reported as applied, but it could not be verified with an admin SQL Editor session from this environment. The Flutter CLI is available; Supabase CLI and `psql` are not.

## Pending live verification

1. Run [supabase/migrations/202609290002_public_trip_browse_view.sql](../supabase/migrations/202609290002_public_trip_browse_view.sql) in the configured project's SQL Editor.
2. In that SQL Editor, run the following read-only check to establish whether the development auth user and deterministic seed rows exist, including rows hidden by RLS from the app client:

	 ```sql
	 select
		 (select count(*) from auth.users where email = 'dev.driver@local.test') as driver_auth_user,
		 (select count(*) from public.routes where id = '11111111-1111-4111-8111-111111111111'::uuid) as seeded_route,
		 (select count(*) from public.route_stops where route_id = '11111111-1111-4111-8111-111111111111'::uuid) as seeded_stops,
		 (select count(*) from public.trips where id in (
			 '55555555-5555-4555-8555-555555555555'::uuid,
			 '66666666-6666-4666-8666-666666666666'::uuid
		 )) as seeded_trips;
	 ```

3. If `driver_auth_user` is zero, create the development driver through normal signup, then run [supabase/seed.sql](../supabase/seed.sql). The seed now raises an error instead of silently doing nothing when this prerequisite is missing.
4. Verify the public projection returns only intentionally public fields:

	 ```sql
	 select id, direction, route_name, route_stops, driver_name,
					driver_verification_status, vehicle_make, vehicle_model,
					vehicle_color, vehicle_seat_capacity
	 from public.trip_browse
	 order by departure_time;
	 ```

5. Verify the app's publishable-key query returns both trips and that outbound/reverse stop sequences render in opposite display order.
6. Continue the existing RPC, booking-capacity, cancellation, concurrency, and passenger/driver/admin RLS checks before claiming full backend verification.

## Status

Status: PENDING LIVE VERIFICATION. The configured public API returned zero rows for the expected seed IDs; the `trip_browse` view returned HTTP 404, confirming the new view migration is not applied there yet.

This section is intentionally left as a checklist for a machine that has the correct Supabase credentials and CLI access.
