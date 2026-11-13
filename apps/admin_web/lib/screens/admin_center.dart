import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';

/// The Center an Admin runs. The Admin's other screens start from here.
class AdminCenterScreen extends StatefulWidget {
  const AdminCenterScreen({super.key, required this.api, required this.center});

  final DefaultApi api;
  final CenterAccess center;

  @override
  State<AdminCenterScreen> createState() => _AdminCenterScreenState();
}

class _AdminCenterScreenState extends State<AdminCenterScreen> {
  late final Future<CenterProfile?> _profile = widget.api.getCenter(widget.center.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.center.name)),
      body: FutureBuilder(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Can't load your Center. Try again."));
          final profile = snapshot.data;
          if (profile == null) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: [
              const ListTile(leading: Icon(Icons.verified_user_outlined), title: Text('You are an Admin here')),
              ListTile(title: const Text('Timezone'), subtitle: Text(profile.timezone)),
              ListTile(title: const Text('Currency'), subtitle: Text(profile.currency.value)),
            ],
          );
        },
      ),
    );
  }
}
