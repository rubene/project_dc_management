import 'dart:convert';

import 'package:dc_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app.dart';
import 'auth/amplify_auth.dart';
import 'auth/id_token_authentication.dart';
import 'browser_timezone.dart';
import 'invitation_link.dart';

// The Admin web app's CloudFront distribution also serves the API under /v1,
// so the app calls its own origin and needs no CORS. Set API_URL to point a
// local build somewhere else.
const _apiUrl = String.fromEnvironment('API_URL');

// Each deploy writes the stage's user pool to /config.json. A local build can
// pass them instead, with --dart-define.
const _userPoolId = String.fromEnvironment('USER_POOL_ID');
const _appClientId = String.fromEnvironment('APP_CLIENT_ID');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiUrl = _apiUrl.isNotEmpty ? _apiUrl : Uri.base.resolve('/v1').toString();
  final auth = await AmplifyAuth.configure(await _cognitoConfig());
  final api = DefaultApi(ApiClient(basePath: apiUrl, authentication: IdTokenAuthentication(auth)));
  runApp(DcAdminWebApp(
    auth: auth,
    api: api,
    browserTimezone: browserTimezone(),
    appUrl: Uri.base,
    invitation: InvitationLink.fromUri(Uri.base),
  ));
}

Future<CognitoConfig> _cognitoConfig() async {
  if (_userPoolId.isNotEmpty) {
    return const CognitoConfig(region: 'us-west-2', userPoolId: _userPoolId, appClientId: _appClientId);
  }
  final response = await http.get(Uri.base.resolve('/config.json'));
  return CognitoConfig.fromJson(jsonDecode(response.body) as Map<String, Object?>);
}
