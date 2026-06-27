import 'package:flutter_test/flutter_test.dart';
import 'package:math_buddy/app.dart';

void main() {
  testWidgets('Uygulama açılış testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MathBuddyApp());
    expect(find.text('Hesapla'), findsOneWidget);
  });
}
