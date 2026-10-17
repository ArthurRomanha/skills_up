// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_test_app/main.dart';

void main() {
  testWidgets('App abre com a barra de navegação', (WidgetTester tester) async {
    //simula o sharedpreferences vazio (o app usa ele)
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MeuApp());
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Agenda'), findsWidgets);
  });
}
