import 'package:flutter/material.dart';

import 'form.dart';

/// Why the invitation the app was opened with can't be used. Signing out
/// keeps the invitation, so the person can sign in with the invited email.
class InvitationProblemScreen extends StatelessWidget {
  const InvitationProblemScreen({
    super.key,
    required this.message,
    required this.onContinue,
    required this.onSignOut,
  });

  final String message;
  final VoidCallback onContinue;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => FormPage(
    title: "This invitation can't be used",
    message: message,
    actionLabel: 'Continue without it',
    onAction: onContinue,
    secondary: TextButton(onPressed: onSignOut, child: const Text('Sign out')),
    children: const [],
  );
}
