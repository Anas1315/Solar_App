import 'package:flutter_test/flutter_test.dart';
import 'package:smart_energy_controller/main.dart';

void main() {
  testWidgets('Smart Energy app opens on the solar home screen',
      (tester) async {
    await tester.pumpWidget(const SmartEnergyApp(autoConnect: false));
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Production'), findsOneWidget);
    expect(find.text('Consumption'), findsOneWidget);
    expect(find.text('Grid Voltage'), findsOneWidget);
    expect(find.text('WAPDA:'), findsOneWidget);
    expect(find.text('Heavy Load'), findsOneWidget);
  });
}
