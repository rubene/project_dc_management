/// The link an Owner sends to invite someone to a Center. It opens the Admin
/// web app with the Center's ID and the invitation's token.
class InvitationLink {
  const InvitationLink({required this.centerId, required this.token});

  final String centerId;
  final String token;

  /// The invitation in the address the app was opened at, if there is one.
  static InvitationLink? fromUri(Uri uri) {
    final centerId = uri.queryParameters['center'];
    final token = uri.queryParameters['invitation'];
    if (centerId == null || centerId.isEmpty || token == null || token.isEmpty) return null;
    return InvitationLink(centerId: centerId, token: token);
  }

  /// The link, on the app at [appUrl].
  Uri toUri(Uri appUrl) =>
      appUrl.removeFragment().replace(queryParameters: {'center': centerId, 'invitation': token});
}
