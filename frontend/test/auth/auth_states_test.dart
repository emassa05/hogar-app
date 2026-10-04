import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/storage/token_storage.dart';
import 'package:hogar_app/core/theme/app_theme.dart';
import 'package:hogar_app/core/widgets/otp_code_field.dart';
import 'package:hogar_app/features/auth/domain/auth_entities.dart';
import 'package:hogar_app/features/auth/presentation/auth_controller.dart';
import 'package:hogar_app/features/auth/presentation/auth_flow_state.dart';
import 'package:hogar_app/features/auth/presentation/auth_strings.dart';
import 'package:hogar_app/features/auth/presentation/screens/character_screen.dart';
import 'package:hogar_app/features/auth/presentation/screens/code_screen.dart';
import 'package:hogar_app/features/auth/presentation/screens/login_screen.dart';
import 'package:hogar_app/features/auth/presentation/screens/password_screen.dart';
import 'package:hogar_app/features/auth/presentation/screens/phone_screen.dart';
import 'package:hogar_app/features/auth/presentation/widgets/access_illustration.dart';

import '../support/memory_token_storage.dart';

class _FakeAuth extends AuthController {
  _FakeAuth(this.initial);
  final AuthFlowState initial;
  @override
  AuthFlowState build() => initial;
}

PhoneVerification _verification({Duration resendIn = Duration.zero}) =>
    PhoneVerification(
      id: 'verification-id',
      phone: '+56987654321',
      purpose: VerificationPurpose.registration,
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 10)),
      resendAvailableAt: DateTime.now().toUtc().add(resendIn),
    );

ApiException _error(
  ApiErrorCode code,
  int status,
  Map<String, dynamic> details,
) => ApiException(statusCode: status, code: code, details: details);

Finder _semantics(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

Future<void> _pump(
  WidgetTester tester,
  Widget screen,
  AuthFlowState state, {
  double scale = 1,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
        authControllerProvider.overrideWith(() => _FakeAuth(state)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: screen,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('login maps invalid credentials to the password field', (
    tester,
  ) async {
    await _pump(
      tester,
      const LoginScreen(),
      AuthFlowState(
        error: _error(ApiErrorCode.invalidCredentials, 401, {
          'remaining_attempts': 1,
        }),
      ),
    );
    expect(
      find.text(
        'La contraseña no coincide con ese número. Te queda 1 intento.',
      ),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('account lock shows a countdown and disables sign in', (
    tester,
  ) async {
    await _pump(
      tester,
      const LoginScreen(),
      AuthFlowState(
        blockedUntil: DateTime.now().toUtc().add(const Duration(minutes: 15)),
        error: _error(ApiErrorCode.accountLocked, 423, {
          'retry_after_seconds': 900,
        }),
      ),
    );
    expect(
      find.textContaining('Podrás volver a intentarlo en 15:00'),
      findsOneWidget,
    );
    final enter = tester.widget<Semantics>(_semantics(AuthStrings.enter));
    expect(enter.properties.enabled, isFalse);
  });

  testWidgets('resend shows a countdown until it becomes available', (
    tester,
  ) async {
    await _pump(
      tester,
      const CodeScreen(),
      AuthFlowState(
        verification: _verification(resendIn: const Duration(seconds: 42)),
      ),
    );
    expect(find.textContaining('Podrás pedir otro en'), findsOneWidget);
    expect(find.textContaining('0:4'), findsOneWidget);
  });

  testWidgets('resend becomes a link once the wait is over', (tester) async {
    await _pump(
      tester,
      const CodeScreen(),
      AuthFlowState(verification: _verification()),
    );
    expect(
      _semantics('${AuthStrings.resendPrompt}${AuthStrings.resend}'),
      findsOneWidget,
    );
  });

  testWidgets('invalid code shows remaining attempts in error state', (
    tester,
  ) async {
    await _pump(
      tester,
      const CodeScreen(),
      AuthFlowState(
        verification: _verification(),
        errorPulse: 1,
        error: _error(ApiErrorCode.verificationCodeInvalid, 400, {
          'remaining_attempts': 3,
        }),
      ),
    );
    expect(
      find.text('El código no coincide. Te quedan 3 intentos.'),
      findsOneWidget,
    );
    expect(
      tester.widget<OtpCodeField>(find.byType(OtpCodeField)).status,
      OtpStatus.error,
    );
  });

  testWidgets('password checklist ticks rules while typing', (tester) async {
    await _pump(
      tester,
      const PasswordScreen(),
      AuthFlowState(verification: _verification()),
    );
    expect(find.text('0 de 4'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'Segura12');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('4 de 4'), findsOneWidget);
    final rule = tester.widget<Semantics>(_semantics('Una letra mayúscula'));
    expect(rule.properties.checked, isTrue);
  });

  testWidgets('character can be picked, changed or skipped', (tester) async {
    await _pump(
      tester,
      const CharacterScreen(),
      const AuthFlowState(name: 'Marta', password: 'Segura12'),
    );
    expect(find.text(AuthStrings.skipCharacter), findsOneWidget);
    await tester.ensureVisible(find.bySemanticsLabel('Personaje verde'));
    await tester.tap(find.bySemanticsLabel('Personaje verde'));
    await tester.pumpAndSettle();
    expect(find.text(AuthStrings.changeCharacter), findsOneWidget);
    expect(find.text(AuthStrings.skipCharacter), findsNothing);
    await tester.ensureVisible(find.text(AuthStrings.changeCharacter));
    await tester.tap(find.text(AuthStrings.changeCharacter));
    await tester.pumpAndSettle();
    expect(find.text(AuthStrings.skipCharacter), findsOneWidget);
  });

  testWidgets('large text hides decoration and keeps actions reachable', (
    tester,
  ) async {
    await _pump(tester, const PhoneScreen(), const AuthFlowState(), scale: 2);
    expect(find.byType(AccessIllustration), findsNothing);
    expect(find.text(AuthStrings.sendCode), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
