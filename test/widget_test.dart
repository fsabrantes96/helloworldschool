import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:helloworldschool/main.dart';

void main() {
  testWidgets('Teste de renderização da tela inicial', (
    WidgetTester tester,
  ) async {
    // Construa nosso app e acione um frame
    await tester.pumpWidget(MyApp()); // Removido o const

    // Verifique se os botões principais estão presentes
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Registrar'), findsOneWidget);
  });

  testWidgets('Teste de navegação para a tela de login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp());

    // Toque no botão de Login
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(); // Aguarde a animação de navegação

    // Verifique se a tela de login foi aberta
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('Teste de navegação para a tela de registro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp());

    // Toque no botão de Registrar
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    // Verifique se a tela de registro foi aberta
    expect(find.text('Nome completo'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Telefone'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });
}
