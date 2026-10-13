import 'package:flutter_test/flutter_test.dart';

import 'package:citalis_app/main.dart';

void main() {
  testWidgets('Citalis welcome screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CitalisApp());
    expect(find.text('Citalis'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Ya tengo cuenta'), findsOneWidget);
  });
}
