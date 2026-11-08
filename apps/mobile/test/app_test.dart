import 'dart:convert';

import 'package:dc_api_client/api.dart';
import 'package:dc_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// The real generated client, with the network replaced by a fake API that
// answers GET /health the way the OpenAPI definition describes.
DefaultApi fakeApi(Future<http.Response> Function() health) {
  final client = ApiClient(basePath: 'https://api.example.test/v1')
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

    await tester.pumpWidget(DcMobileApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('The API is up'), findsOneWidget);
    expect(find.text('Server time: 2026-01-01 09:30 UTC'), findsOneWidget);
  });

  testWidgets("says the database is unavailable when the API can't read it", (
    tester,
  ) async {
    final api = fakeApi(
      () async => jsonResponse(503, {
        'status': 'unavailable',
        'database': 'unavailable',
      }),
    );

    await tester.pumpWidget(DcMobileApp(api: api));
    await tester.pumpAndSettle();

    expect(
      find.text("The API is running but can't reach its database"),
      findsOneWidget,
    );
    expect(find.text('The API is up'), findsNothing);
  });

  testWidgets("says it can't reach the API when the request fails", (
    tester,
  ) async {
    final api = fakeApi(
      () async => throw http.ClientException('Connection refused'),
    );

    await tester.pumpWidget(DcMobileApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text("Can't reach the API"), findsOneWidget);
  });
}
