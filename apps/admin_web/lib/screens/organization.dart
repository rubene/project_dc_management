import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';

import 'form.dart';

/// The Organization the person owns, as the Centers screens need it.
class OwnedOrganization {
  const OwnedOrganization({required this.id, required this.name});

  final String id;
  final String name;
}

/// A new Owner creates their Organization together with its first Center.
class CreateOrganizationScreen extends StatefulWidget {
  const CreateOrganizationScreen({
    super.key,
    required this.api,
    required this.browserTimezone,
    required this.onCreated,
  });

  final DefaultApi api;
  final String browserTimezone;
  final void Function(OwnedOrganization organization) onCreated;

  @override
  State<CreateOrganizationScreen> createState() => _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState extends State<CreateOrganizationScreen> {
  final _name = TextEditingController();
  final _center = CenterFields();
  // Made once per form, so a retry sends the same ID and can't create the
  // Organization twice.
  final _orgId = Ulid().toString().toUpperCase();
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _center.timezone.text = widget.browserTimezone;
  }

  Future<void> _create() async {
    setState(() => _busy = true);
    late Organization? created;
    final error = await attempt(() async {
      created = await widget.api.createOrganization(
        NewOrganization(id: _orgId, name: _name.text.trim(), center: _center.toNewCenter()),
      );
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) widget.onCreated(OwnedOrganization(id: created!.id, name: created!.name));
  }

  @override
  Widget build(BuildContext context) => FormPage(
    title: 'Set up your Organization',
    message: 'Your Organization is your business. Each daycare location is a Center, and you can add more later.',
    error: _error,
    busy: _busy,
    actionLabel: 'Create Organization',
    onAction: _create,
    children: [
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Organization name')),
      ...centerFieldInputs(_center, nameLabel: 'First Center name', onChanged: () => setState(() {})),
    ],
  );
}

/// A new Center's fields: name, the currency it bills in, and its timezone.
class CenterFields {
  final name = TextEditingController();
  final timezone = TextEditingController();
  // Made once per form, so a retry sends the same ID.
  final id = Ulid().toString().toUpperCase();
  Currency currency = Currency.USD;

  NewCenter toNewCenter() =>
      NewCenter(id: id, name: name.text.trim(), currency: currency, timezone: timezone.text.trim());
}

/// The inputs for [CenterFields]. [onChanged] redraws the form when the
/// currency changes.
List<Widget> centerFieldInputs(CenterFields center, {required String nameLabel, required VoidCallback onChanged}) => [
  TextField(controller: center.name, decoration: InputDecoration(labelText: nameLabel)),
  SegmentedButton<Currency>(
    segments: [for (final currency in Currency.values) ButtonSegment(value: currency, label: Text('$currency'))],
    selected: {center.currency},
    onSelectionChanged: (selected) {
      center.currency = selected.single;
      onChanged();
    },
  ),
  TextField(
    controller: center.timezone,
    decoration: const InputDecoration(
      labelText: 'Timezone',
      helperText: 'Filled in from this browser. Change it if the Center is somewhere else.',
    ),
  ),
];
