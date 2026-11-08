import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';

/// Calls the API's health check and shows the result.
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key, required this.api, required this.title});

  final DefaultApi api;
  final String title;

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late final Future<Health?> _health = widget.api.getHealth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: FutureBuilder(
          future: _health,
          builder: (context, snapshot) {
            final error = snapshot.error;
            // 503 is the API's documented answer when it can't read its
            // database (see api/openapi.yaml).
            if (error is ApiException && error.code == 503) {
              return const Text(
                "The API is running but can't reach its database",
              );
            }
            if (error != null) return const Text("Can't reach the API");
            final health = snapshot.data;
            if (health == null) return const CircularProgressIndicator();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('The API is up'),
                Text('Server time: ${_formatUtc(health.time)}'),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _formatUtc(DateTime time) {
  final utc = time.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${utc.year}-${two(utc.month)}-${two(utc.day)} '
      '${two(utc.hour)}:${two(utc.minute)} UTC';
}
