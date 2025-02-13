import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('Testa a exibição da lista de planetas', (WidgetTester tester) async {
    await tester.pumpWidget(PlanetApp());

    expect(find.text('Planetas'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Testa a adição de um novo planeta', (WidgetTester tester) async {
    await tester.pumpWidget(PlanetApp());

    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsOneWidget);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Simulação de entrada de dados
    await tester.enterText(find.byType(TextField).at(0), 'Terra');
    await tester.enterText(find.byType(TextField).at(1), '1.0');
    await tester.enterText(find.byType(TextField).at(2), '12742');

    final saveButton = find.text('Salvar');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Terra'), findsOneWidget);
  });

  testWidgets('Testa a exclusão de um planeta', (WidgetTester tester) async {
    await tester.pumpWidget(PlanetApp());

    await tester.pumpAndSettle();

    final deleteButton = find.byIcon(Icons.delete).first;
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
  });
}
