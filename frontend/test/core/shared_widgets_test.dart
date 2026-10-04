import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/motion/pressable_scale.dart';
import 'package:hogar_app/core/session/session_user.dart';
import 'package:hogar_app/core/theme/app_theme.dart';
import 'package:hogar_app/core/widgets/accent_title.dart';
import 'package:hogar_app/core/widgets/app_buttons.dart';
import 'package:hogar_app/core/widgets/app_scaffold.dart';
import 'package:hogar_app/core/widgets/app_text_field.dart';
import 'package:hogar_app/core/widgets/character_picker.dart';
import 'package:hogar_app/core/widgets/otp_code_field.dart';
import 'package:hogar_app/core/widgets/password_field.dart';
import 'package:hogar_app/core/widgets/password_rules_checklist.dart';
import 'package:hogar_app/core/widgets/phone_field.dart';
import 'package:hogar_app/core/widgets/selectable_chip.dart';
import 'package:hogar_app/core/widgets/step_header.dart';

Widget harness(Widget child, {double scale = 1, bool reduced = false}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          disableAnimations: reduced,
        ),
        child: child,
      ),
    );

void main() {
  testWidgets('buttons ignore taps while loading and disabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(
        AppScaffold(
          child: PrimaryButton(
            label: 'Continuar',
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Continuar'));
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpWidget(
      harness(const AppScaffold(child: SecondaryButton(label: 'Compartir'))),
    );
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Compartir',
      ),
    );
    expect(semantics.properties.enabled, isFalse);
  });
  testWidgets('password visibility changes without losing input', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Segura12');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      harness(AppScaffold(child: PasswordField(controller: controller))),
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isFalse,
    );
    expect(controller.text, 'Segura12');
  });
  testWidgets('OTP accepts six digits and exposes one autofill field', (
    tester,
  ) async {
    var code = '';
    await tester.pumpWidget(
      harness(
        AppScaffold(child: OtpCodeField(onChanged: (value) => code = value)),
      ),
    );
    await tester.enterText(find.byType(TextField), '48271599');
    expect(code, '482715');
    expect(
      tester.widget<TextField>(find.byType(TextField)).autofillHints,
      contains(AutofillHints.oneTimeCode),
    );
  });
  testWidgets('character selection exposes selected semantics and callback', (
    tester,
  ) async {
    AvatarChoice? chosen;
    await tester.pumpWidget(
      harness(
        AppScaffold(
          child: CharacterPicker(
            selected: AvatarChoice.indigo,
            onSelected: (value) => chosen = value,
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Personaje verde'));
    expect(chosen, AvatarChoice.green);
    expect(find.bySemanticsLabel('Personaje índigo'), findsOneWidget);
  });
  testWidgets('form actions remain reachable at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var continued = false;
    await tester.pumpWidget(
      harness(
        AppScaffold(
          header: StepHeader(
            title: 'Crear cuenta',
            step: 2,
            total: 4,
            onBack: () {},
          ),
          footer: PrimaryButton(
            label: 'Continuar',
            onPressed: () => continued = true,
          ),
          child: const Column(
            children: [
              AccentTitle(text: 'Crea una ', accent: 'contraseña'),
              SizedBox(height: 20),
              PasswordField(),
              SizedBox(height: 20),
              PasswordRulesChecklist(password: 'Segura12'),
            ],
          ),
        ),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    expect(continued, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('text field shows contract errors with danger styling', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        const AppScaffold(
          child: AppTextField(
            label: 'Nombre',
            errorText: 'Usa un máximo de 40 caracteres.',
            maxLength: 40,
            showCounter: true,
          ),
        ),
      ),
    );
    expect(find.text('Usa un máximo de 40 caracteres.'), findsOneWidget);
    expect(find.text('0/40'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Marta');
    await tester.pump();
    expect(find.text('5/40'), findsOneWidget);
  });
  testWidgets('phone field groups chilean mobile digits', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      harness(AppScaffold(child: PhoneField(controller: controller))),
    );
    await tester.enterText(find.byType(TextField), '+56987654321');
    expect(controller.text, '9 8765 4321');
    expect(find.bySemanticsLabel('Chile, código de país +56'), findsOneWidget);
  });
  testWidgets('chips expose toggled state and 48 dp targets', (tester) async {
    var selected = false;
    await tester.pumpWidget(
      harness(
        AppScaffold(
          child: StatefulBuilder(
            builder: (context, setState) => SelectableChip(
              label: 'Cocinar',
              selected: selected,
              tone: ChipTone.success,
              onSelected: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(SelectableChip)).height, 48);
    await tester.tap(find.text('Cocinar'));
    await tester.pump();
    expect(selected, isTrue);
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Cocinar',
      ),
    );
    expect(semantics.properties.toggled, isTrue);
  });
  testWidgets('step header keeps a 48 dp back target and announces progress', (
    tester,
  ) async {
    var back = 0;
    await tester.pumpWidget(
      harness(
        AppScaffold(
          header: StepHeader(
            title: 'Crear cuenta',
            step: 1,
            total: 4,
            onBack: () => back++,
          ),
          child: const SizedBox(),
        ),
      ),
    );
    final button = find.byType(HeaderIconButton);
    expect(tester.getSize(button), const Size(48, 48));
    await tester.tap(button);
    expect(back, 1);
    expect(find.bySemanticsLabel('Paso 1 de 4'), findsWidgets);
  });
  testWidgets('press feedback uses opacity when reduce motion is enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        const AppScaffold(
          child: PressableScale(child: SizedBox(width: 48, height: 48)),
        ),
        reduced: true,
      ),
    );
    expect(find.byType(AnimatedScale), findsNothing);
    expect(find.byType(AnimatedOpacity), findsOneWidget);
  });
}
