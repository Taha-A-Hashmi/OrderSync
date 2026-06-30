// Smoke test for the OrderSync app: the public landing page is the entry
// point, with a clear "Order Now" call to action (Phase 2 navigation).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ordersync/main.dart';

void main() {
  testWidgets('OrderSync launches on the landing page',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OrderSyncApp());
    await tester.pump();

    // Landing page CTAs are present; no login form fields are shown yet.
    expect(find.text('Order Now'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });
}
