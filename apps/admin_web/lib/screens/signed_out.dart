import 'package:flutter/material.dart';

import '../auth/auth.dart';
import 'form.dart';

/// Signing in, for a person who already has an account.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.auth, required this.onSignedIn, required this.onCreateAccount});

  final Auth auth;
  final void Function(SignInStep step) onSignedIn;
  final VoidCallback onCreateAccount;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    late SignInStep step;
    final error = await attempt(() async {
      step = await widget.auth.signIn(email: _email.text.trim(), password: _password.text);
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) widget.onSignedIn(step);
  }

  @override
  Widget build(BuildContext context) => FormPage(
    title: 'Sign in to DC Management',
    error: _error,
    busy: _busy,
    actionLabel: 'Sign in',
    onAction: _signIn,
    secondary: TextButton(onPressed: widget.onCreateAccount, child: const Text('Create an account')),
    children: [
      TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), autofillHints: const [AutofillHints.email]),
      TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
    ],
  );
}

/// Creating a login. Cognito emails a code to confirm the address.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.auth, required this.onSignedUp, required this.onSignIn});

  final Auth auth;
  final void Function(String email, String password) onSignedUp;
  final VoidCallback onSignIn;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _signUp() async {
    final email = _email.text.trim();
    setState(() => _busy = true);
    final error = await attempt(() => widget.auth.signUp(email: email, password: _password.text));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) widget.onSignedUp(email, _password.text);
  }

  @override
  Widget build(BuildContext context) => FormPage(
    title: 'Create your DC Management account',
    message: "You'll set up your Organization and its first Center next.",
    error: _error,
    busy: _busy,
    actionLabel: 'Create account',
    onAction: _signUp,
    secondary: TextButton(onPressed: widget.onSignIn, child: const Text('I already have an account')),
    children: [
      TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
      TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
    ],
  );
}

/// Confirming the email address with the code Cognito sent, then signing in.
class ConfirmEmailScreen extends StatefulWidget {
  const ConfirmEmailScreen({
    super.key,
    required this.auth,
    required this.email,
    required this.password,
    required this.onSignedIn,
  });

  final Auth auth;
  final String email;
  final String password;
  final void Function(SignInStep step) onSignedIn;

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen> {
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _confirm() async {
    setState(() => _busy = true);
    late SignInStep step;
    final error = await attempt(() async {
      await widget.auth.confirmSignUp(email: widget.email, code: _code.text.trim());
      step = await widget.auth.signIn(email: widget.email, password: widget.password);
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) widget.onSignedIn(step);
  }

  @override
  Widget build(BuildContext context) => FormPage(
    title: 'Confirm your email',
    message: 'We emailed a code to ${widget.email}.',
    error: _error,
    busy: _busy,
    actionLabel: 'Confirm',
    onAction: _confirm,
    children: [TextField(controller: _code, decoration: const InputDecoration(labelText: 'Code'))],
  );
}

/// The second step of signing in, for a login with an authenticator app.
class AuthenticatorCodeScreen extends StatefulWidget {
  const AuthenticatorCodeScreen({super.key, required this.auth, required this.onSignedIn});

  final Auth auth;
  final VoidCallback onSignedIn;

  @override
  State<AuthenticatorCodeScreen> createState() => _AuthenticatorCodeScreenState();
}

class _AuthenticatorCodeScreenState extends State<AuthenticatorCodeScreen> {
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _confirm() async {
    setState(() => _busy = true);
    final error = await attempt(() => widget.auth.confirmSignIn(_code.text.trim()));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) widget.onSignedIn();
  }

  @override
  Widget build(BuildContext context) => FormPage(
    title: 'Enter the code from your authenticator app',
    error: _error,
    busy: _busy,
    actionLabel: 'Sign in',
    onAction: _confirm,
    children: [TextField(controller: _code, decoration: const InputDecoration(labelText: 'Code'))],
  );
}
