import 'package:flutter/material.dart';

import '../auth/auth.dart';
import 'form.dart';

/// Offered once, right after creating an account. MFA with an authenticator
/// app is optional for everyone.
class AuthenticatorOfferScreen extends StatelessWidget {
  const AuthenticatorOfferScreen({super.key, required this.onSetUp, required this.onSkip});

  final VoidCallback onSetUp;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => FormPage(
    title: 'Protect your account with an authenticator app',
    message: 'Each time you sign in, you\'ll also enter a code from an app such as Google Authenticator or 1Password. '
        'You can set it up now or skip it.',
    actionLabel: 'Set up',
    onAction: onSetUp,
    secondary: TextButton(onPressed: onSkip, child: const Text('Not now')),
    children: const [],
  );
}

/// Adds an authenticator app: shows the key to type into the app, then
/// checks a code it shows.
class AuthenticatorSetupScreen extends StatefulWidget {
  const AuthenticatorSetupScreen({super.key, required this.auth, required this.onDone});

  final Auth auth;
  final VoidCallback onDone;

  @override
  State<AuthenticatorSetupScreen> createState() => _AuthenticatorSetupScreenState();
}

class _AuthenticatorSetupScreenState extends State<AuthenticatorSetupScreen> {
  late final Future<AuthenticatorSetup> _setup = widget.auth.startAuthenticatorSetup();
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _turnOn() async {
    setState(() => _busy = true);
    final error = await attempt(() => widget.auth.verifyAuthenticatorSetup(_code.text.trim()));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) widget.onDone();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _setup,
    builder: (context, snapshot) {
      final setup = snapshot.data;
      if (snapshot.hasError) {
        return FormPage(
          title: "Can't set up an authenticator app right now",
          actionLabel: 'Skip for now',
          onAction: widget.onDone,
          children: const [],
        );
      }
      if (setup == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      return FormPage(
        title: 'Add DC Management to your authenticator app',
        message: 'In the app, add an account and type this key, then enter the code it shows.',
        error: _error,
        busy: _busy,
        actionLabel: 'Turn on',
        onAction: _turnOn,
        secondary: TextButton(onPressed: widget.onDone, child: const Text('Not now')),
        children: [
          SelectableText(setup.secret, style: Theme.of(context).textTheme.titleMedium),
          TextField(controller: _code, decoration: const InputDecoration(labelText: 'Code from the app')),
        ],
      );
    },
  );
}
