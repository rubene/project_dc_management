import 'package:dc_admin_web/invitation_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an invitation link opens the app with the same invitation', () {
    const sent = InvitationLink(centerId: '01JCENTER', token: 'a+b/c=');

    final link = sent.toUri(Uri.parse('https://admin.example.test/some/page?x=1#frag'));
    final opened = InvitationLink.fromUri(link)!;

    expect(link.origin, 'https://admin.example.test');
    expect(opened.centerId, '01JCENTER');
    expect(opened.token, 'a+b/c=');
  });

  test('an address without an invitation has none', () {
    expect(InvitationLink.fromUri(Uri.parse('https://admin.example.test/')), isNull);
    expect(InvitationLink.fromUri(Uri.parse('https://admin.example.test/?center=01JCENTER')), isNull);
  });
}
