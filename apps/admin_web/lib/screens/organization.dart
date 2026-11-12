import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';

import '../device_id.dart';
import '../timezones.dart';
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
  late final _center = CenterFields(widget.browserTimezone);
  // Made once per form, so a retry sends the same ID and can't create the
  // Organization twice.
  final _orgId = newDeviceId();
  String? _error;
  bool _busy = false;

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

/// A new Center's fields: name, the currency it bills in, and its timezone,
/// which starts as the browser's.
class CenterFields {
  CenterFields(String browserTimezone)
    : timezone = browserTimezone,
      timezones = timezonesOffered(browserTimezone);

  final name = TextEditingController();
  final List<Timezone> timezones;
  String timezone;
  // Made once per form, so a retry sends the same ID.
  final id = newDeviceId();
  Currency currency = Currency.USD;

  NewCenter toNewCenter() => NewCenter(id: id, name: name.text.trim(), currency: currency, timezone: timezone);
}

/// The inputs for [CenterFields]. [onChanged] redraws the form when the
/// currency or timezone changes.
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
  DropdownButtonFormField<String>(
    initialValue: center.timezone,
    isExpanded: true,
    decoration: const InputDecoration(
      labelText: 'Timezone',
      helperText: "This browser's timezone. Change it if the Center is somewhere else.",
    ),
    items: [
      for (final zone in center.timezones) DropdownMenuItem(value: zone.iana, child: Text(zone.label)),
    ],
    onChanged: (zone) {
      if (zone == null) return;
      center.timezone = zone;
      onChanged();
    },
  ),
];
