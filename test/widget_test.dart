import 'package:flutter_test/flutter_test.dart';
import 'package:kivo_map/main.dart';

void main() {
  testWidgets('shows main navigation tabs', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Khám phá'), findsWidgets);
    expect(find.text('Kho báu'), findsOneWidget);
    expect(find.text('Hồ sơ'), findsOneWidget);
  });
}
