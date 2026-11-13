import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';

import '../invitation_link.dart';
import 'form.dart';

/// The Center an Owner is looking at, from their list of Centers.
class OwnedCenter {
  const OwnedCenter({required this.id, required this.name});

  final String id;
  final String name;
}

/// A Center's Admins, for an Owner: invite one, appoint themselves, or
/// remove one (A7).
class CenterAdminsScreen extends StatefulWidget {
  const CenterAdminsScreen({
    super.key,
    required this.api,
    required this.center,
    required this.ownerPersonId,
    required this.appUrl,
  });

  final DefaultApi api;
  final OwnedCenter center;

  /// The signed-in Owner's person ID, so they can appoint themselves.
  final String ownerPersonId;

  /// Where the app is served, for invitation links.
  final Uri appUrl;

  @override
  State<CenterAdminsScreen> createState() => _CenterAdminsScreenState();
}

class _CenterAdminsScreenState extends State<CenterAdminsScreen> {
  late Future<AdminList?> _admins = _load();
  String? _error;

  Future<AdminList?> _load() => widget.api.listAdmins(widget.center.id);

  void _reload() {
    if (!mounted) return;
    setState(() {
      _admins = _load();
    });
  }

  Future<void> _change(Future<void> Function() action) async {
    final error = await attempt(action);
    if (!mounted) return;
    setState(() => _error = error);
    _reload();
  }

  void _invite() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => InviteAdminScreen(api: widget.api, center: widget.center, appUrl: widget.appUrl),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.center;
    return Scaffold(
      appBar: AppBar(title: Text(center.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _invite,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Invite an Admin'),
      ),
      body: FutureBuilder(
        future: _admins,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Can't load the Admins. Try again."));
          final admins = snapshot.data?.admins;
          if (admins == null) return const Center(child: CircularProgressIndicator());
          final isAdmin = admins.any((admin) => admin.personId == widget.ownerPersonId);
          return ListView(
            children: [
              const ListTile(title: Text('Admins')),
              if (admins.isEmpty) const ListTile(title: Text('No Admins yet')),
              for (final admin in admins)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(admin.personId == widget.ownerPersonId ? '${admin.name} (you)' : admin.name),
                  subtitle: Text(admin.email),
                  trailing: TextButton(
                    onPressed: () => _change(() => widget.api.removeAdmin(center.id, admin.personId)),
                    child: Text('Remove ${admin.name}'),
                  ),
                ),
              if (!isAdmin)
                ListTile(
                  title: OutlinedButton(
                    onPressed: () => _change(() => widget.api.appointSelfAsAdmin(center.id, widget.ownerPersonId)),
                    child: const Text('Make me an Admin here too'),
                  ),
                ),
              if (_error != null)
                ListTile(title: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
            ],
          );
        },
      ),
    );
  }
}

/// Invites a person to be a Center's Admin, then shows the link to send them.
class InviteAdminScreen extends StatefulWidget {
  const InviteAdminScreen({super.key, required this.api, required this.center, required this.appUrl});

  final DefaultApi api;
  final OwnedCenter center;
  final Uri appUrl;

  @override
  State<InviteAdminScreen> createState() => _InviteAdminScreenState();
}

class _InviteAdminScreenState extends State<InviteAdminScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  String? _error;
  bool _busy = false;
  Uri? _link;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _busy = true);
    Invitation? invitation;
    final error = await attempt(() async {
      invitation = await widget.api.createInvitation(
        widget.center.id,
        NewInvitation(role: InvitableRole.admin, name: _name.text.trim(), email: _email.text.trim()),
      );
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
      final created = invitation;
      if (created != null) {
        _link = InvitationLink(centerId: created.centerId, token: created.token).toUri(widget.appUrl);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final link = _link;
    if (link != null) {
      return FormPage(
        title: 'Send ${_name.text.trim()} this link',
        message: 'It works once, for ${_email.text.trim()}, for 7 days. This is the only time it\'s shown.',
        actionLabel: 'Done',
        onAction: () => Navigator.of(context).pop(),
        children: [SelectableText(link.toString())],
      );
    }
    return FormPage(
      title: 'Invite an Admin to ${widget.center.name}',
      message: 'They sign in with this email to accept.',
      error: _error,
      busy: _busy,
      actionLabel: 'Create invitation',
      onAction: _create,
      children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Their name')),
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Their email'),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}
