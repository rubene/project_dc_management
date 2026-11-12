import 'package:dc_admin_web/app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_backend.dart';
import 'support/steps.dart';

void main() {
  testWidgets('an Owner with an authenticator app enters its code to sign in', (tester) async {
    final backend = FakeBackend()
      ..addPerson('ana@example.test', 'pw-1', name: 'Ana Owner', withAuthenticatorApp: true);
    await tester.pumpWidget(DcAdminWebApp(auth: backend.auth, api: backend.api, browserTimezone: 'America/Vancouver'));

    await signIn(tester, 'ana@example.test', 'pw-1');
    expect(find.text('Enter the code from your authenticator app'), findsOneWidget);
    await enter(tester, 'Code', FakeAuth.authenticatorCode);
    await tap(tester, 'Sign in');

    expect(find.text('Set up your Organization'), findsOneWidget);
  });

  testWidgets('a wrong password is explained, and nothing else happens', (tester) async {
    final backend = FakeBackend()..addPerson('ana@example.test', 'pw-1', name: 'Ana Owner');
    await tester.pumpWidget(DcAdminWebApp(auth: backend.auth, api: backend.api, browserTimezone: 'America/Vancouver'));

    await signIn(tester, 'ana@example.test', 'not-it');

    expect(find.text('Incorrect email or password'), findsOneWidget);
    expect(backend.requests, isEmpty);
  });
}
