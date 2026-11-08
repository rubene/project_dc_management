import 'package:dc_api_client/api.dart';
import 'package:dc_ui/dc_ui.dart';
import 'package:flutter/material.dart';

/// The app for Staff and Guardians.
class DcMobileApp extends StatelessWidget {
  const DcMobileApp({super.key, required this.api});

  final DefaultApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC Management',
      theme: dcTheme(),
      home: HealthScreen(api: api, title: 'DC Management'),
    );
  }
}
