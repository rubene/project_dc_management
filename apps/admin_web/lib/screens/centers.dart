import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';

import 'admins.dart';
import 'form.dart';
import 'organization.dart';

/// An Owner's Organization and its Centers (C2).
class CentersScreen extends StatefulWidget {
  const CentersScreen({
    super.key,
    required this.api,
    required this.organization,
    required this.ownerPersonId,
    required this.browserTimezone,
    required this.appUrl,
  });

  final DefaultApi api;
  final OwnedOrganization organization;
  final String ownerPersonId;
  final String browserTimezone;
  final Uri appUrl;

  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  late Future<CenterList?> _centers = _load();

  Future<CenterList?> _load() => widget.api.listCenters(widget.organization.id);

  void _addCenter() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => AddCenterScreen(
        api: widget.api,
        organization: widget.organization,
        browserTimezone: widget.browserTimezone,
        onAdded: () {
          if (!mounted) return;
          setState(() {
            _centers = _load();
          });
        },
      ),
    ));
  }

  void _openCenter(OwnedCenter center) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CenterAdminsScreen(
        api: widget.api,
        center: center,
        ownerPersonId: widget.ownerPersonId,
        appUrl: widget.appUrl,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.organization.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCenter,
        icon: const Icon(Icons.add),
        label: const Text('Add a Center'),
      ),
      body: FutureBuilder(
        future: _centers,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Can't load your Centers. Try again."));
          final centers = snapshot.data?.centers;
          if (centers == null) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: [
              const ListTile(title: Text('Centers')),
              for (final center in centers)
                ListTile(
                  leading: const Icon(Icons.home_work_outlined),
                  title: Text(center.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openCenter(OwnedCenter(id: center.id, name: center.name)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Adds another Center to the Owner's Organization.
class AddCenterScreen extends StatefulWidget {
  const AddCenterScreen({
    super.key,
    required this.api,
    required this.organization,
    required this.browserTimezone,
    required this.onAdded,
  });

  final DefaultApi api;
  final OwnedOrganization organization;
  final String browserTimezone;

  /// Called once the Center is saved, before going back.
  final VoidCallback onAdded;

  @override
  State<AddCenterScreen> createState() => _AddCenterScreenState();
}

class _AddCenterScreenState extends State<AddCenterScreen> {
  late final _center = CenterFields(widget.browserTimezone);
  String? _error;
  bool _busy = false;

  Future<void> _add() async {
    setState(() => _busy = true);
    final error = await attempt(() => widget.api.addCenter(widget.organization.id, _center.toNewCenter()));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error != null) return;
    widget.onAdded();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => FormPage(
    title: 'Add a Center to ${widget.organization.name}',
    error: _error,
    busy: _busy,
    actionLabel: 'Add Center',
    onAction: _add,
    children: centerFieldInputs(_center, nameLabel: 'Center name', onChanged: () => setState(() {})),
  );
}
