import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_advanced_example/main.dart';

void main() {
  testWidgets('shows the USSD field and the three actions', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Ussd Plugin example'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Normal request'), findsOneWidget);
    expect(find.text('Single session request'), findsOneWidget);
    expect(find.text('Multi session request'), findsOneWidget);
  });
}
