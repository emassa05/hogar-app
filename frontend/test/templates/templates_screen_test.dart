import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/router/route_names.dart';
import 'package:hogar_app/features/households/presentation/household_strings.dart';
import 'package:hogar_app/features/templates/presentation/screens/templates_screen.dart';

import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_screen_harness.dart';

Future<ResponseBody> Function(RequestOptions) _responder(
  List<RequestOptions> writes, {
  ResponseBody Function(RequestOptions)? onApply,
}) => (request) async {
  final path = request.path;
  if (request.method == 'POST') {
    writes.add(request);
    if (onApply != null) return onApply(request);
    final keys = (requestBody(request)['template_keys'] as List).cast<String>();
    return jsonResponse(
      applicationJson(keys: keys, count: keys.isEmpty ? 0 : 25),
      201,
    );
  }
  if (path == '/households/household-1') return jsonResponse(householdJson());
  if (path == '/household-templates') {
    return jsonResponse([templateJson(), templateJson(key: 'pets', count: 6)]);
  }
  if (path == '/household-templates/family') {
    return jsonResponse(templateJson(detail: true));
  }
  if (path == '/household-templates/pets') {
    return jsonResponse(templateJson(key: 'pets', count: 6, detail: true));
  }
  return jsonResponse(<String, dynamic>{});
};

void main() {
  testWidgets('A9 shows a live total and applies the selection', (
    tester,
  ) async {
    final writes = <RequestOptions>[];
    await pumpN2Screen(
      tester,
      const TemplatesScreen(householdId: 'household-1'),
      _responder(writes),
    );
    expect(find.text(HouseholdStrings.willAdd(0)), findsOneWidget);
    await tapText(tester, 'Familia con niñas o niños');
    expect(find.text(HouseholdStrings.willAdd(19)), findsOneWidget);
    expect(find.text('Poner la lavadora'), findsOneWidget);
    await tapText(tester, 'Vivo con mascotas');
    expect(find.text(HouseholdStrings.willAdd(25)), findsOneWidget);
    expect(find.text(HouseholdStrings.addTasks(25)), findsOneWidget);
    await tapText(tester, HouseholdStrings.addTasks(25));
    expect(requestBody(writes.single)['template_keys'], ['family', 'pets']);
    expect(writes.single.headers['Idempotency-Key'], isNotNull);
    expect(find.text(HouseholdStrings.applied), findsOneWidget);
    expect(find.text(HouseholdStrings.appliedTasks(25)), findsOneWidget);
    await tapText(tester, HouseholdStrings.enterHome);
    expect(find.text(RouteNames.home), findsOneWidget);
  });

  testWidgets('A9 can start empty', (tester) async {
    final writes = <RequestOptions>[];
    await pumpN2Screen(
      tester,
      const TemplatesScreen(householdId: 'household-1'),
      _responder(writes),
    );
    await tapText(tester, HouseholdStrings.startEmpty);
    expect(requestBody(writes.single)['template_keys'], isEmpty);
    expect(find.text(HouseholdStrings.appliedEmpty), findsOneWidget);
  });

  testWidgets('A9 keeps the selection and offers retry on failure', (
    tester,
  ) async {
    final writes = <RequestOptions>[];
    await pumpN2Screen(
      tester,
      const TemplatesScreen(householdId: 'household-1'),
      _responder(
        writes,
        onApply: (request) => apiError('SERVICE_UNAVAILABLE', 503),
      ),
    );
    await tapText(tester, 'Vivo con mascotas');
    await tapText(tester, HouseholdStrings.addTasks(6));
    expect(find.text(HouseholdStrings.applied), findsNothing);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text(HouseholdStrings.willAdd(6)), findsOneWidget);
  });

  testWidgets('A9 stays usable at 200 percent text', (tester) async {
    await pumpN2Screen(
      tester,
      const TemplatesScreen(householdId: 'household-1'),
      _responder([]),
      scale: 2,
    );
    expect(find.text(HouseholdStrings.startEmpty), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
