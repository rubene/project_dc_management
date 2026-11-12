import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';

import '../auth/auth.dart';
import 'form.dart';

/// Signs up the person behind a new login (PUT /me), then gets new tokens,
/// because only tokens issued after sign-up carry the person ID.
class YourNameScreen extends StatefulWidget {
  const YourNameScreen({super.key, required this.auth, required this.api, required this.onSignedUp});

  final Auth auth;
  final DefaultApi api;
  final VoidCallback onSignedUp;

  @override
  State<YourNameScreen> createState() => _YourNameScreenState();
}

class _YourNameScreenState extends State<YourNameScreen> {
  final _name = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _continue() async {
    setState(() => _busy = true);
    final error = await attempt(() async {
      await widget.api.signUp(SignUp(name: _name.text.trim()));
      await widget.auth.idToken(forceRefresh: true);
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) widget.onSignedUp();
  }

  @override
  Widget build(BuildContext context) => FormPage(
    title: "What's your name?",
    message: 'Families and Staff will see it.',
    error: _error,
    busy: _busy,
    actionLabel: 'Continue',
    onAction: _continue,
    children: [TextField(controller: _name, decoration: const InputDecoration(labelText: 'Your name'))],
  );
}
