import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';

import 'app.dart';

// The API's URL for the stage this build talks to, such as the ApiUrl
// output in backend/cdk-outputs.dev.json:
//   flutter run --dart-define=API_URL=https://<api-id>.execute-api.us-west-2.amazonaws.com/v1
const _apiUrl = String.fromEnvironment('API_URL');

void main() {
  if (_apiUrl.isEmpty) {
    throw StateError('Build with --dart-define=API_URL=<the API URL>');
  }
  // The generated client adds paths like "/health" to the base path, so it
  // must not end with a slash.
  final basePath = _apiUrl.endsWith('/')
      ? _apiUrl.substring(0, _apiUrl.length - 1)
      : _apiUrl;
  runApp(DcMobileApp(api: DefaultApi(ApiClient(basePath: basePath))));
}
