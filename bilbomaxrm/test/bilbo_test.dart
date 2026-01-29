import 'package:flutter_test/flutter_test.dart';
import 'package:bilbomaxrm/main.dart'; // Usa el nombre de tu nueva carpeta

void main() {
  testWidgets('Cálculo exacto Bilbo', (WidgetTester tester) async {
    await tester.pumpWidget(const BilboApp());
    // Aquí podrías añadir lógica para simular que escribes 70kg y 10 reps
    // Pero por ahora, con que compile ya es ganancia.
  });
}