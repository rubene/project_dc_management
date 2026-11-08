import 'dart:convert';

import 'package:dc_admin_web/app.dart';
import 'package:dc_api_client/api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// The real generated client, with the network replaced by a fake API that
// answers GET /health the way the OpenAPI definition describes.
DefaultApi fakeApi(Future<http.Response> Function() health) {
  final client = ApiClient(basePath: 'https://admin.example.test/v1')
    ..client = MockClient((request) async {
      if (request.method == 'GET' && request.url.path == '/v1/health') {
        return health();
      }
      return jsonResponse(404, {'message': 'Not found'});
    });
  return DefaultApi(client);
}

http.Response jsonResponse(int status, Object body) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  testWidgets('shows that the API is up, with the server time', (tester) async {
    final api = fakeApi(
      () async => jsonResponse(200, {
        'status': 'ok',
        'database': 'ok',
        'time': '2026-01-01T09:30:00.000Z',
      }),
    );

    await tester.pumpWidget(DcAdminWebApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('DC Management Admin'), findsOneWidget);
    expect(find.text('The API is up'), findsOneWidget);
    expect(find.text('Server time: 2026-01-01 09:30 UTC'), findsOneWidget);
  });
}
