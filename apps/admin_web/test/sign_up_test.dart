import 'package:dc_admin_web/app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_backend.dart';
import 'support/steps.dart';

void main() {
  testWidgets('a new Owner creates an account, confirms their email and is offered an authenticator app',
      (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(DcAdminWebApp(auth: backend.auth, api: backend.api, browserTimezone: 'America/Vancouver'));
    await tester.pumpAndSettle();

    await tap(tester, 'Create an account');
    await enter(tester, 'Email', 'ana@example.test');
    await enter(tester, 'Password', 'a-long-password-1');
    await tap(tester, 'Create account');
    expect(find.textContaining('We emailed a code to ana@example.test'), findsOneWidget);
    await enter(tester, 'Code', FakeAuth.emailCode);
    await tap(tester, 'Confirm');

    expect(find.text('Protect your account with an authenticator app'), findsOneWidget);
    expect(await backend.auth.isSignedIn(), isTrue);
  });

  // Only tokens issued after PUT /me carry the person ID, so the app gets new
  // ones before going on.
  testWidgets('after skipping the authenticator app, the Owner gives their name and is signed up', (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(DcAdminWebApp(auth: backend.auth, api: backend.api, browserTimezone: 'America/Vancouver'));
    await createAccount(tester, 'ana@example.test');

    await tap(tester, 'Not now');
    expect(find.text("What's your name?"), findsOneWidget);
    await enter(tester, 'Your name', 'Ana Owner');
    await tap(tester, 'Continue');

    expect(backend.requests, contains('PUT /me'));
    expect(backend.auth.refreshes, 1);
    expect(find.text('Set up your Organization'), findsOneWidget);
  });

  testWidgets('a new Owner who chooses to add an authenticator app with its key and a code', (tester) async {
    final backend = FakeBackend();
    await tester.pumpWidget(DcAdminWebApp(auth: backend.auth, api: backend.api, browserTimezone: 'America/Vancouver'));
    await createAccount(tester, 'ana@example.test');

    await tap(tester, 'Set up');
    expect(find.text('FAKESECRET'), findsOneWidget);
    await enter(tester, 'Code from the app', FakeAuth.authenticatorCode);
    await tap(tester, 'Turn on');

    expect(backend.auth.hasAuthenticatorApp, isTrue);
    expect(find.text("What's your name?"), findsOneWidget);
  });
}

/// Creates and confirms an account, ending on the authenticator app offer.
Future<void> createAccount(WidgetTester tester, String email) async {
  await tester.pumpAndSettle();
  await tap(tester, 'Create an account');
  await enter(tester, 'Email', email);
  await enter(tester, 'Password', 'a-long-password-1');
  await tap(tester, 'Create account');
  await enter(tester, 'Code', FakeAuth.emailCode);
  await tap(tester, 'Confirm');
}
