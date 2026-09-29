# Development seed

1. Open the Supabase project in the browser.
2. Go to SQL Editor.
3. Run the migrations in filename order if they have not already been applied:
   - `supabase/migrations/202609290001_initial_wasselni_schema.sql`
   - `supabase/migrations/202609290002_public_trip_browse_view.sql`
4. Ensure an auth user already exists with email `dev.driver@local.test`. Create it through the app's normal signup flow if necessary; do not insert directly into `auth.users`.
5. Open `supabase/seed.sql` and copy its contents into the SQL Editor. To use another existing driver account, update `v_dev_email` near the start of the script.
6. Press Run. The script now raises an error if the required auth user is missing instead of silently succeeding without inserting data.
7. Confirm that the route, route stops, driver, vehicle, and two published trips were inserted.

This seed intentionally does not create fake auth users or fake bookings. It creates development data only for an existing auth user.

If you want to seed booking records later, create the passenger auth user first, then use the real `auth.users.id` and `public.profiles.id` values as the `passenger_id` in a later booking insert. The booking seed must be created only after the passenger account exists.

The route seeded here is:

- Minyet El-Nasr
- Mit Ghamr
- Benha
- Cairo

The database includes both an outbound trip and a reverse-direction trip for the same route. The script only inserts data for a driver whose auth user already exists.
