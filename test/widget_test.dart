import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crisismesh/main.dart';

void main() {
  testWidgets('CrisisMeshApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CrisisMeshApp()));
    expect(find.byType(CrisisMeshApp), findsOneWidget);
  });
}
