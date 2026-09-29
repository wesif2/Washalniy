import 'package:flutter_test/flutter_test.dart';
import 'package:rides_app/features/profiles/domain/profile.dart';

void main() {
  test('profile role remains unset until selected', () {
    final profile = Profile.fromSupabase({'id': 'user-1', 'role': null});

    expect(profile.role, isNull);
  });

  test('profile parses the persisted passenger or driver role', () {
    expect(
      Profile.fromSupabase({'id': 'user-1', 'role': 'passenger'}).role,
      'passenger',
    );
    expect(
      Profile.fromSupabase({'id': 'user-2', 'role': 'driver'}).role,
      'driver',
    );
  });
}
