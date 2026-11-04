import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:citalis_app/config/dependencies.dart';
import 'package:citalis_app/main.dart';

void main() {
  // En pruebas no hay red: las fuentes no se descargan y se usa la del sistema.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('La pantalla de bienvenida muestra la marca y sus dos acciones', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(providers: fakeRepositories(), child: const CitalisApp()),
    );

    expect(find.text('CITALIS'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Ya tengo una cuenta'), findsOneWidget);
  });
}
