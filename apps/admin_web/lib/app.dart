import 'package:dc_api_client/api.dart';
import 'package:dc_ui/dc_ui.dart';
import 'package:flutter/material.dart';

/// The web app for Admins.
class DcAdminWebApp extends StatelessWidget {
  const DcAdminWebApp({super.key, required this.api});

  final DefaultApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC Management Admin',
      theme: dcTheme(),
      home: HealthScreen(api: api, title: 'DC Management Admin'),
    );
  }
}
