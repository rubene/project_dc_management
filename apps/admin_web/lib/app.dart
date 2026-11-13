import 'dart:convert';

import 'package:dc_api_client/api.dart';
import 'package:dc_ui/dc_ui.dart';
import 'package:flutter/material.dart';

import 'auth/auth.dart';
import 'invitation_link.dart';
import 'screens/admin_center.dart';
import 'screens/authenticator_offer.dart';
import 'screens/centers.dart';
import 'screens/organization.dart';
import 'screens/signed_out.dart';
import 'screens/your_name.dart';

/// The web app for Owners and Admins.
class DcAdminWebApp extends StatelessWidget {
  const DcAdminWebApp({
    super.key,
    required this.auth,
    required this.api,
    required this.browserTimezone,
    this.appUrl,
    this.invitation,
  });

  final Auth auth;
  final DefaultApi api;

  /// The browser's IANA timezone, offered as a new Center's timezone.
  final String browserTimezone;

  /// Where the app is served, for invitation links. Defaults to where it was
  /// opened.
  final Uri? appUrl;

  /// The invitation the app was opened with, accepted once the person has
  /// signed in.
  final InvitationLink? invitation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC Management Admin',
      theme: dcTheme(),
      home: AdminHome(
        auth: auth,
        api: api,
        browserTimezone: browserTimezone,
        appUrl: appUrl ?? Uri.base,
        invitation: invitation,
      ),
    );
  }
}

/// Where the person is, from signing in to working with their Centers.
sealed class _Stage {
  const _Stage();
}

class _SigningIn extends _Stage {
  const _SigningIn();
}

class _CreatingAccount extends _Stage {
  const _CreatingAccount();
}

class _ConfirmingEmail extends _Stage {
  const _ConfirmingEmail(this.email, this.password);

  final String email;
  final String password;
}

class _OfferingAuthenticator extends _Stage {
  const _OfferingAuthenticator();
}

class _SettingUpAuthenticator extends _Stage {
  const _SettingUpAuthenticator();
}

class _EnteringAuthenticatorCode extends _Stage {
  const _EnteringAuthenticatorCode();
}

/// Signed in; finding out who the person is (GET /me).
class _SignedIn extends _Stage {
  const _SignedIn();
}

/// The login hasn't signed up yet (GET /me answered 403).
class _GivingName extends _Stage {
  const _GivingName();
}

/// The invitation the app was opened with can't be used, and why.
class _InvitationProblem extends _Stage {
  const _InvitationProblem(this.message);

  final String message;
}

/// An Admin who isn't an Owner, at the Center they run.
class _RunningCenter extends _Stage {
  const _RunningCenter(this.center);

  final CenterAccess center;
}

class _CreatingOrganization extends _Stage {
  const _CreatingOrganization();
}

class _ManagingCenters extends _Stage {
  const _ManagingCenters(this.organization, {required this.personId});

  final OwnedOrganization organization;
  final String personId;
}

class AdminHome extends StatefulWidget {
  const AdminHome({
    super.key,
    required this.auth,
    required this.api,
    required this.browserTimezone,
    required this.appUrl,
    this.invitation,
  });

  final Auth auth;
  final DefaultApi api;
  final String browserTimezone;
  final Uri appUrl;
  final InvitationLink? invitation;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  _Stage _stage = const _SigningIn();

  /// The invitation still to accept, until it's been tried once.
  late InvitationLink? _invitation = widget.invitation;

  void _go(_Stage stage) {
    setState(() => _stage = stage);
    if (stage is _SignedIn) _findWhoTheyAre();
  }

  Future<void> _findWhoTheyAre() async {
    try {
      var me = await widget.api.getMe();
      if (!mounted || me == null) return;
      final invitation = _invitation;
      if (invitation != null) {
        _invitation = null;
        final problem = await _accept(invitation);
        if (!mounted) return;
        if (problem != null) return _go(_InvitationProblem(problem));
        me = await widget.api.getMe();
        if (!mounted || me == null) return;
      }
      // v1 Owners have one Organization, and Admins one Center; more would
      // need a picker here.
      final owned = me.organizations.firstOrNull;
      final run = me.centers.firstOrNull;
      _go(switch ((owned, run)) {
        (final owned?, _) => _ManagingCenters(OwnedOrganization(id: owned.id, name: owned.name), personId: me.personId),
        (null, final run?) => _RunningCenter(run),
        (null, null) => const _CreatingOrganization(),
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 403) _go(const _GivingName());
    }
  }

  /// Accepts an invitation, or says why it can't be.
  Future<String?> _accept(InvitationLink invitation) async {
    try {
      await widget.api.acceptInvitation(invitation.centerId, InvitationAcceptance(token: invitation.token));
      return null;
    } on ApiException catch (error) {
      if (error.code != 403 && error.code != 404) rethrow;
      return _messageOf(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.auth;
    return switch (_stage) {
      _SigningIn() => SignInScreen(
        auth: auth,
        onSignedIn: (step) => _go(switch (step) {
          SignInStep.done => const _SignedIn(),
          SignInStep.authenticatorCode => const _EnteringAuthenticatorCode(),
        }),
        onCreateAccount: () => _go(const _CreatingAccount()),
      ),
      _CreatingAccount() => SignUpScreen(
        auth: auth,
        onSignedUp: (email, password) => _go(_ConfirmingEmail(email, password)),
        onSignIn: () => _go(const _SigningIn()),
      ),
      _ConfirmingEmail(:final email, :final password) => ConfirmEmailScreen(
        auth: auth,
        email: email,
        password: password,
        onSignedIn: (_) => _go(const _OfferingAuthenticator()),
      ),
      _EnteringAuthenticatorCode() => AuthenticatorCodeScreen(auth: auth, onSignedIn: () => _go(const _SignedIn())),
      _OfferingAuthenticator() => AuthenticatorOfferScreen(
        onSetUp: () => _go(const _SettingUpAuthenticator()),
        onSkip: () => _go(const _SignedIn()),
      ),
      _SettingUpAuthenticator() => AuthenticatorSetupScreen(auth: auth, onDone: () => _go(const _SignedIn())),
      _SignedIn() => const Scaffold(body: Center(child: CircularProgressIndicator())),
      _GivingName() => YourNameScreen(auth: auth, api: widget.api, onSignedUp: () => _go(const _SignedIn())),
      _InvitationProblem(:final message) => InvitationProblemScreen(
        message: message,
        onContinue: () => _go(const _SignedIn()),
      ),
      _RunningCenter(:final center) => AdminCenterScreen(key: ValueKey(center.id), api: widget.api, center: center),
      _CreatingOrganization() => CreateOrganizationScreen(
        api: widget.api,
        browserTimezone: widget.browserTimezone,
        // Finding out who they are again gives their person ID.
        onCreated: (_) => _go(const _SignedIn()),
      ),
      _ManagingCenters(:final organization, :final personId) => CentersScreen(
        key: ValueKey(organization.id),
        api: widget.api,
        organization: organization,
        ownerPersonId: personId,
        browserTimezone: widget.browserTimezone,
        appUrl: widget.appUrl,
      ),
    };
  }
}

/// The API's explanation in an error response, such as "This invitation is
/// for a different email address".
String _messageOf(ApiException error) {
  try {
    final body = jsonDecode(error.message ?? '');
    if (body is Map && body['message'] is String) return body['message'] as String;
  } on FormatException {
    // Not JSON; fall through.
  }
  return 'Something went wrong. Try the link again.';
}
