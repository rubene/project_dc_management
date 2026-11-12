import 'package:dc_api_client/api.dart';

import 'auth.dart';

/// Sends the signed-in person's current ID token with every API request.
/// API Gateway checks it and passes its claims to the API.
class IdTokenAuthentication implements Authentication {
  IdTokenAuthentication(this._auth);

  final Auth _auth;

  @override
  Future<void> applyToParams(List<QueryParam> queryParams, Map<String, String> headerParams) async {
    if (!await _auth.isSignedIn()) return;
    headerParams['Authorization'] = 'Bearer ${await _auth.idToken()}';
  }
}
