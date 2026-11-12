import 'package:dc_api_client/api.dart';
import 'package:dc_ui/dc_ui.dart';
import 'package:flutter/material.dart';

import 'auth/auth.dart';
import 'screens/authenticator_offer.dart';
import 'screens/centers.dart';
import 'screens/organization.dart';
import 'screens/signed_out.dart';
import 'screens/your_name.dart';

/// The web app for Owners and Admins.
class DcAdminWebApp extends StatelessWidget {
  const DcAdminWebApp({super.key, required this.auth, required this.api, required this.browserTimezone});

  final Auth auth;
  final DefaultApi api;

  /// The browser's IANA timezone, offered as a new Center's timezone.
  final String browserTimezone;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC Management Admin',
      theme: dcTheme(),
      home: AdminHome(auth: auth, api: api, browserTimezone: browserTimezone),
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

class _CreatingOrganization extends _Stage {
  const _CreatingOrganization();
}

class _ManagingCenters extends _Stage {
  const _ManagingCenters(this.organization);

  final OwnedOrganization organization;
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key, required this.auth, required this.api, required this.browserTimezone});

  final Auth auth;
  final DefaultApi api;
  final String browserTimezone;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  _Stage _stage = const _SigningIn();

  void _go(_Stage stage) {
    setState(() => _stage = stage);
    if (stage is _SignedIn) _findWhoTheyAre();
  }

  Future<void> _findWhoTheyAre() async {
    try {
      final me = await widget.api.getMe();
      if (!mounted || me == null) return;
      // v1 Owners have one Organization; more would need a picker here.
      final owned = me.organizations.firstOrNull;
      _go(owned == null
          ? const _CreatingOrganization()
          : _ManagingCenters(OwnedOrganization(id: owned.id, name: owned.name)));
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 403) _go(const _GivingName());
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
      _CreatingOrganization() => CreateOrganizationScreen(
        api: widget.api,
        browserTimezone: widget.browserTimezone,
        onCreated: (organization) => _go(_ManagingCenters(organization)),
      ),
      _ManagingCenters(:final organization) => CentersScreen(
        key: ValueKey(organization.id),
        api: widget.api,
        organization: organization,
        browserTimezone: widget.browserTimezone,
      ),
    };
  }
}
