import 'package:dc_admin_web/app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_backend.dart';
import 'support/steps.dart';

void main() {
  testWidgets('an Owner sets up their Organization and its first Center, in the browser\'s timezone or another',
      (tester) async {
    final backend = FakeBackend()..addPerson('ana@example.test', 'pw-1', name: 'Ana Owner');
    await tester.pumpWidget(DcAdminWebApp(auth: backend.auth, api: backend.api, browserTimezone: 'America/Vancouver'));
    await signIn(tester, 'ana@example.test', 'pw-1');

    expect(find.text('Set up your Organization'), findsOneWidget);
    expect(find.text('Pacific – Vancouver (America/Vancouver)'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('CAD'), findsOneWidget);

    await enter(tester, 'Organization name', 'Little Oaks');
    await enter(tester, 'First Center name', 'Little Oaks Downtown');
    await tap(tester, 'CAD');
    await tap(tester, 'Pacific – Vancouver (America/Vancouver)');
    await tap(tester, 'Mountain – Edmonton (America/Edmonton)');
    await tap(tester, 'Create Organization');

    final [sent] = backend.bodies['POST /organizations']!;
    expect(sent['name'], 'Little Oaks');
    expect(sent['center'], containsPair('currency', 'CAD'));
    expect(sent['center'], containsPair('timezone', 'America/Edmonton'));
    expect(find.text('Little Oaks'), findsOneWidget);
    expect(find.text('Little Oaks Downtown'), findsOneWidget);
  });

  // The list is the US and Canadian zones, but the browser's own zone is
  // always offered, even if it's elsewhere.
  testWidgets("a browser timezone outside the list is still offered, and chosen", (tester) async {
    final backend = FakeBackend()..addPerson('ana@example.test', 'pw-1', name: 'Ana Owner');
    await tester.pumpWidget(DcAdminWebApp(auth: backend.auth, api: backend.api, browserTimezone: 'Europe/Madrid'));
    await signIn(tester, 'ana@example.test', 'pw-1');

    await setUpOrganization(tester, name: 'Little Oaks', firstCenter: 'Little Oaks Downtown');

    expect(backend.bodies['POST /organizations']!.single['center'], containsPair('timezone', 'Europe/Madrid'));
  });

  testWidgets('an Owner adds another Center to their Organization', (tester) async {
    final backend = FakeBackend()..addPerson('ana@example.test', 'pw-1', name: 'Ana Owner');
    await tester.pumpWidget(DcAdminWebApp(auth: backend.auth, api: backend.api, browserTimezone: 'America/Vancouver'));
    await signIn(tester, 'ana@example.test', 'pw-1');
    await setUpOrganization(tester, name: 'Little Oaks', firstCenter: 'Little Oaks Downtown');

    await tap(tester, 'Add a Center');
    expect(find.text('Pacific – Vancouver (America/Vancouver)'), findsOneWidget);
    await enter(tester, 'Center name', 'Little Oaks Uptown');
    await tap(tester, 'Add Center');

    expect(backend.bodies['POST /organizations/${orgIdOf(backend)}/centers'], hasLength(1));
    expect(find.text('Little Oaks Downtown'), findsOneWidget);
    expect(find.text('Little Oaks Uptown'), findsOneWidget);
  });
}

Future<void> setUpOrganization(WidgetTester tester, {required String name, required String firstCenter}) async {
  await enter(tester, 'Organization name', name);
  await enter(tester, 'First Center name', firstCenter);
  await tap(tester, 'Create Organization');
}

String orgIdOf(FakeBackend backend) => backend.bodies['POST /organizations']!.single['id']! as String;
