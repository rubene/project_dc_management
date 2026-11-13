import 'dart:convert';

import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';

/// The layout every signed-out and setup screen shares: a title, fields, an
/// error if the last attempt failed, and the main action.
class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.title,
    this.message,
    required this.children,
    this.error,
    required this.actionLabel,
    required this.onAction,
    this.busy = false,
    this.secondary,
  });

  final String title;
  final String? message;
  final List<Widget> children;
  final String? error;
  final String actionLabel;
  final VoidCallback onAction;
  final bool busy;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (message != null) ...[const SizedBox(height: 8), Text(message!)],
                const SizedBox(height: 24),
                for (final child in children) ...[child, const SizedBox(height: 16)],
                if (error != null) ...[
                  Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 16),
                ],
                FilledButton(onPressed: busy ? null : onAction, child: Text(actionLabel)),
                if (secondary != null) ...[const SizedBox(height: 8), secondary!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Runs [action], turning failures into a message for the person.
Future<String?> attempt(Future<void> Function() action) async {
  try {
    await action();
    return null;
  } on ApiException catch (error) {
    return apiMessage(error);
  } on Exception catch (error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

/// The API's explanation in an error response, such as "This invitation is
/// for a different email address".
String apiMessage(ApiException error) {
  try {
    final body = jsonDecode(error.message ?? '');
    if (body is Map && body['message'] is String) return body['message'] as String;
  } on FormatException {
    // Not JSON, such as a gateway's error page.
  }
  return 'Something went wrong. Try again.';
}
