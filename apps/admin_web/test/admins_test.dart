import 'package:dc_admin_web/app.dart';
import 'package:dc_admin_web/invitation_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_backend.dart';
import 'support/steps.dart';

final appUrl = Uri.parse('https://admin.example.test/');

/// An Owner with an Organization and one Center, Little Oaks Downtown.
({FakeBackend backend, String centerId}) ownerWithCenter() {
  final backend = FakeBackend()..addPerson('ana@example.test', 'pw-1', name: 'Ana Owner');
  final centerId = backend.addOrganization(
    ownerEmail: 'ana@example.test',
    name: 'Little Oaks',
    centerName: 'Little Oaks Downtown',
  );
  return (backend: backend, centerId: centerId);
}

Widget app(FakeBackend backend, {InvitationLink? invitation}) => DcAdminWebApp(
  auth: backend.auth,
  api: backend.api,
  browserTimezone: 'America/Vancouver',
  appUrl: appUrl,
  invitation: invitation,
);

void main() {
  testWidgets('an Owner invites an Admin to a Center and gets a link to send them', (tester) async {
    final (:backend, :centerId) = ownerWithCenter();
    await tester.pumpWidget(app(backend));
    await signIn(tester, 'ana@example.test', 'pw-1');

    await tap(tester, 'Little Oaks Downtown');
    await tap(tester, 'Invite an Admin');
    await enter(tester, 'Their name', 'Ari Admin');
    await enter(tester, 'Their email', 'ari@example.test');
    await tap(tester, 'Create invitation');

    final [sent] = backend.bodies['POST /centers/$centerId/invitations']!;
    expect(sent, {'role': 'Admin', 'name': 'Ari Admin', 'email': 'ari@example.test'});
    final link = InvitationLink(centerId: centerId, token: 'token-1').toUri(appUrl).toString();
    expect(find.text(link), findsOneWidget);
  });

  testWidgets('an invited Admin opens the link, signs in and runs their Center', (tester) async {
    final (:backend, :centerId) = ownerWithCenter();
    backend.addPerson('ari@example.test', 'pw-2', name: 'Ari Admin');
    final token = backend.addInvitation(centerId, 'ari@example.test');

    await tester.pumpWidget(app(backend, invitation: InvitationLink(centerId: centerId, token: token)));
    await signIn(tester, 'ari@example.test', 'pw-2');

    expect(backend.isAdmin(centerId, 'ari@example.test'), isTrue);
    expect(find.text('Little Oaks Downtown'), findsOneWidget);
    expect(find.text('You are an Admin here'), findsOneWidget);
    expect(find.text('Set up your Organization'), findsNothing);
  });

  testWidgets("someone invited who has no account yet creates one from the link", (tester) async {
    final (:backend, :centerId) = ownerWithCenter();
    final token = backend.addInvitation(centerId, 'ari@example.test');
    await tester.pumpWidget(app(backend, invitation: InvitationLink(centerId: centerId, token: token)));
    await tester.pumpAndSettle();

    await tap(tester, 'Create an account');
    await enter(tester, 'Email', 'ari@example.test');
    await enter(tester, 'Password', 'a-long-password-1');
    await tap(tester, 'Create account');
    await enter(tester, 'Code', FakeAuth.emailCode);
    await tap(tester, 'Confirm');
    await tap(tester, 'Not now');
    await enter(tester, 'Your name', 'Ari Admin');
    await tap(tester, 'Continue');

    expect(backend.isAdmin(centerId, 'ari@example.test'), isTrue);
    expect(find.text('You are an Admin here'), findsOneWidget);
  });

  testWidgets('an Admin who signs in later goes straight to their Center', (tester) async {
    final (:backend, :centerId) = ownerWithCenter();
    backend.addPerson('ari@example.test', 'pw-2', name: 'Ari Admin');
    final token = backend.addInvitation(centerId, 'ari@example.test');
    await tester.pumpWidget(app(backend, invitation: InvitationLink(centerId: centerId, token: token)));
    await signIn(tester, 'ari@example.test', 'pw-2');
    await backend.auth.signOut();

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(backend));
    await signIn(tester, 'ari@example.test', 'pw-2');

    expect(find.text('You are an Admin here'), findsOneWidget);
    expect(find.text('Little Oaks Downtown'), findsOneWidget);
  });

  testWidgets("a link for another email says so, and doesn't make them an Admin", (tester) async {
    final (:backend, :centerId) = ownerWithCenter();
    backend.addPerson('sam@example.test', 'pw-3', name: 'Sam Stranger');
    final token = backend.addInvitation(centerId, 'ari@example.test');

    await tester.pumpWidget(app(backend, invitation: InvitationLink(centerId: centerId, token: token)));
    await signIn(tester, 'sam@example.test', 'pw-3');

    expect(find.textContaining('This invitation is for a different email address'), findsOneWidget);
    expect(backend.isAdmin(centerId, 'sam@example.test'), isFalse);
    await tap(tester, 'Continue without it');
    expect(find.text('Set up your Organization'), findsOneWidget);
  });

  testWidgets('an Owner makes themselves their Center\'s Admin too', (tester) async {
    final (:backend, :centerId) = ownerWithCenter();
    await tester.pumpWidget(app(backend));
    await signIn(tester, 'ana@example.test', 'pw-1');
    await tap(tester, 'Little Oaks Downtown');
    expect(find.text('No Admins yet'), findsOneWidget);

    await tap(tester, 'Make me an Admin here too');

    expect(backend.isAdmin(centerId, 'ana@example.test'), isTrue);
    expect(find.text('Ana Owner (you)'), findsOneWidget);
    expect(find.text('Make me an Admin here too'), findsNothing);
  });

  testWidgets('an Owner removes an Admin', (tester) async {
    final (:backend, :centerId) = ownerWithCenter();
    backend.addPerson('ari@example.test', 'pw-2', name: 'Ari Admin');
    final token = backend.addInvitation(centerId, 'ari@example.test');
    await tester.pumpWidget(app(backend, invitation: InvitationLink(centerId: centerId, token: token)));
    await signIn(tester, 'ari@example.test', 'pw-2');
    await backend.auth.signOut();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(backend));
    await signIn(tester, 'ana@example.test', 'pw-1');
    await tap(tester, 'Little Oaks Downtown');
    expect(find.text('Ari Admin'), findsOneWidget);

    await tap(tester, 'Remove Ari Admin');

    expect(backend.isAdmin(centerId, 'ari@example.test'), isFalse);
    expect(find.text('Ari Admin'), findsNothing);
  });
}
