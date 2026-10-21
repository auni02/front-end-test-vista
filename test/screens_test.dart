import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_end_test_vista/main.dart';
import 'package:front_end_test_vista/providers/company_provider.dart';
import 'package:front_end_test_vista/screens/create_company_screen.dart';
import 'package:front_end_test_vista/screens/create_service_screen.dart';
import 'package:front_end_test_vista/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

const _companies = [
  {
    'id': 2,
    'name': 'Juara Inovasi Pasifik Sdn Bhd',
    'registrationNumber': '2040000120',
    'services': [
      {'id': 1, 'companyId': 2, 'name': 'Cleaning', 'description': 'Office cleaning', 'price': 150},
      {'id': 2, 'companyId': 2, 'name': 'Gardening', 'description': 'Weekly care', 'price': 99.5},
    ],
  },
  {'id': 1, 'name': 'Acme Sdn Bhd', 'registrationNumber': 'X1', 'services': []},
];

CompanyProvider _provider() {
  final client = MockClient((request) async => http.Response(jsonEncode(_companies), 200));
  return CompanyProvider(ApiService(client: client))..fetchCompanies();
}

Future<void> _pumpAt(WidgetTester tester, Size size, Widget home) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => _provider(),
      child: home,
    ),
  );
  // Animation loop forever, pumpAndSettle hang, so pump fixed time je
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const sizes = {'phone': Size(390, 844), 'desktop': Size(1440, 900)};

  for (final entry in sizes.entries) {
    testWidgets('company list renders on ${entry.key}', (tester) async {
      await _pumpAt(tester, entry.value, const VistaApp());

      expect(find.text('COMPANIES'), findsOneWidget);
      expect(find.text('Acme Sdn Bhd'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('RM 150.00'),
        300,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );
      expect(find.text('RM 150.00'), findsOneWidget);
    });

    testWidgets('create company form validates on ${entry.key}', (tester) async {
      await _pumpAt(tester, entry.value, const MaterialApp(home: CreateCompanyScreen()));

      await tester.tap(find.text('Save company'));
      await tester.pump();
      expect(find.text('Please enter the company name'), findsOneWidget);
      expect(find.text('Please enter the registration number'), findsOneWidget);
    });

    testWidgets('create service form validates price on ${entry.key}', (tester) async {
      await _pumpAt(tester, entry.value, const MaterialApp(home: CreateServiceScreen(initialCompanyId: 2)));

      await tester.enterText(find.widgetWithText(TextFormField, 'Price'), 'abc');
      await tester.tap(find.text('Save service'));
      await tester.pump();
      expect(find.text('Price must be a number, e.g. 150.50'), findsOneWidget);
    });
  }
}
