import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rides_app/app.dart';
import 'package:rides_app/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('unauthenticated users are sent to login before role selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const WassalniApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('How do you want to use Wasselni?'), findsNothing);
  });
}
