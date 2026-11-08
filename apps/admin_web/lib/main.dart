import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';

import 'app.dart';

// The Admin web app's CloudFront distribution also serves the API under /v1,
// so the app calls its own origin and needs no CORS. Set API_URL to point a
// local build somewhere else.
const _apiUrl = String.fromEnvironment('API_URL');

void main() {
  final apiUrl = _apiUrl.isNotEmpty
      ? _apiUrl
      : Uri.base.resolve('/v1').toString();
  runApp(DcAdminWebApp(api: DefaultApi(ApiClient(basePath: apiUrl))));
}
