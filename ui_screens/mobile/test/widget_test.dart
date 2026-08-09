import 'package:flutter_test/flutter_test.dart';

import 'package:foodscan_mobile/main.dart';

void main() {
  testWidgets('Splash screen shows Get Started', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodScanApp());

    expect(find.text('FoodScan'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
