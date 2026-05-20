import 'package:flutter_test/flutter_test.dart';

import 'package:arisan_digitalv2/main.dart';

void main() {
  testWidgets('Arisan Digital app renders correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ArisanDigitalApp());

    // Verify welcome text appears
    expect(find.text('SELAMAT DATANG DI'), findsOneWidget);
    expect(find.text('ARISAN'), findsOneWidget);
    expect(find.text('DIGITAL'), findsOneWidget);

    // Verify role selection text appears
    expect(find.text('Mau jadi apakah anda?'), findsOneWidget);

    // Verify buttons are present
    expect(find.text('PENGELOLA'), findsOneWidget);
    expect(find.text('PESERTA'), findsOneWidget);
  });
}
