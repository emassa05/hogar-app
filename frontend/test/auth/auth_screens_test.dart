import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/app.dart';
import 'package:hogar_app/core/storage/token_storage.dart';
import 'package:hogar_app/features/auth/data/auth_remote_data_source.dart';
import 'package:hogar_app/features/auth/data/auth_repository_impl.dart';
import 'package:hogar_app/features/auth/presentation/auth_strings.dart';

import '../support/fake_http_adapter.dart';
import '../support/memory_token_storage.dart';
import 'auth_repository_test.dart' show sessionJson, verificationJson;

Future<void> tapLabel(WidgetTester tester, String label) async {
  await tester.pumpAndSettle();
  final finder = find.text(label).last;
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'registration navigates from welcome to verified account and cannot go back to auth',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dio = Dio()
        ..httpClientAdapter = FakeHttpAdapter((request) async {
          if (request.path == '/auth/phone-verifications') {
            return jsonResponse(verificationJson(), 202);
          }
          if (request.path.endsWith('/confirm')) {
            return jsonResponse({
              'verification_token': 'proof',
              'expires_at': DateTime.now()
                  .add(const Duration(minutes: 15))
                  .toIso8601String(),
            });
          }
          return jsonResponse(sessionJson(), 201);
        });
      addTearDown(dio.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
            authRepositoryProvider.overrideWithValue(
              AuthRepositoryImpl(AuthRemoteDataSource(dio)),
            ),
          ],
          child: const HogarApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tapLabel(tester, AuthStrings.createAccount);
      await tester.enterText(find.byType(EditableText).first, '987654321');
      await tapLabel(tester, AuthStrings.sendCode);
      await tester.enterText(find.byType(EditableText).first, '482715');
      await tapLabel(tester, AuthStrings.verify);
      await tester.enterText(find.byType(EditableText).first, 'Segura12');
      await tapLabel(tester, 'Continuar');
      await tester.enterText(find.byType(EditableText).first, 'Marta');
      await tapLabel(tester, 'Continuar');
      await tester.ensureVisible(find.bySemanticsLabel('Personaje verde'));
      await tester.tap(find.bySemanticsLabel('Personaje verde'));
      await tester.pumpAndSettle();
      await tapLabel(tester, AuthStrings.createMyAccount);
      expect(find.text(AuthStrings.createdBody), findsOneWidget);
      await tapLabel(tester, AuthStrings.start);
      expect(find.text(AuthStrings.enter), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(AuthStrings.sendCode), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'login displays remaining attempts and preserves inputs on failure at 200 percent',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dio = Dio()
        ..httpClientAdapter = FakeHttpAdapter(
          (request) async =>
              apiError('INVALID_CREDENTIALS', 401, {'remaining_attempts': 4}),
        );
      addTearDown(dio.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
            authRepositoryProvider.overrideWithValue(
              AuthRepositoryImpl(AuthRemoteDataSource(dio)),
            ),
          ],
          child: const HogarApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tapLabel(tester, AuthStrings.existingAccount);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold));
      final data = MediaQuery.of(context);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.routerConfig, isNotNull);
      await tester.enterText(find.byType(EditableText).first, '987654321');
      await tester.enterText(find.byType(EditableText).last, 'wrong');
      await tapLabel(tester, AuthStrings.enter);
      expect(find.textContaining('Te quedan 4 intentos'), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).last)
            .controller
            .text,
        'wrong',
      );
      expect(data.size.width, 390);
      expect(tester.takeException(), isNull);
    },
  );
}
