import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rides_app/app.dart';

void main() {
  testWidgets('app renders the role-selection screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WassalniApp(),
      ),
    );

    expect(find.text('هتكمل إزاي؟'), findsOneWidget);
  });
}
