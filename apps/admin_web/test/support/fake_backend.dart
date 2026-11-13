import 'dart:convert';

import 'package:dc_admin_web/auth/auth.dart';
import 'package:dc_admin_web/auth/id_token_authentication.dart';
import 'package:dc_api_client/api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A stand-in for Cognito and the API together, so screen tests run the real
/// generated client against answers shaped like `api/openapi.yaml`.
///
/// Like the real system, an ID token carries the person ID only if it was
/// issued after the login signed up, and the API refuses requests without a
/// token (401) or without a person ID (403).
class FakeBackend {
  final _logins = <String, _Login>{};
  final _people = <String, Map<String, Object?>>{};
  final _organizations = <String, Map<String, Object?>>{};
  final _centers = <String, List<Map<String, Object?>>>{};
  int _nextPerson = 1;

  /// The person IDs of each Center's Admins, by Center ID.
  final _admins = <String, Set<String>>{};

  /// Unused invitations, by token: the Center ID and the invited email.
  final _invitations = <String, ({String centerId, String email})>{};
  int _nextToken = 1;

  /// Requests the API received, as "METHOD /path".
  final requests = <String>[];

  /// The JSON bodies the API received, by "METHOD /path".
  final bodies = <String, List<Map<String, Object?>>>{};

  late final FakeAuth auth = FakeAuth(this);

  late final DefaultApi api = DefaultApi(
    ApiClient(
      basePath: 'https://admin.example.test/v1',
      authentication: IdTokenAuthentication(auth),
    )..client = MockClient(_handle),
  );

  /// A login that already exists and is confirmed, such as a returning Owner.
  void addLogin(String email, String password, {bool withAuthenticatorApp = false}) {
    _logins[email] = _Login(password)
      ..confirmed = true
      ..totpEnabled = withAuthenticatorApp;
  }

  /// A login that has also signed up as a person, such as a returning Owner.
  void addPerson(String email, String password, {required String name, bool withAuthenticatorApp = false}) {
    addLogin(email, password, withAuthenticatorApp: withAuthenticatorApp);
    final personId = 'person-${_nextPerson++}';
    _logins[email]!.personId = personId;
    _people[personId] = {'personId': personId, 'name': name, 'email': email};
  }

  /// An Organization with one Center, owned by a person already added with
  /// [addPerson]. Returns the Center's ID.
  String addOrganization({required String ownerEmail, required String name, required String centerName}) {
    final orgId = 'org-${_organizations.length + 1}';
    final centerId = '$orgId-center-1';
    _organizations[orgId] = {'id': orgId, 'name': name, 'ownerId': _personIdFor(ownerEmail)};
    _centers[orgId] = [
      {'id': centerId, 'orgId': orgId, 'name': centerName, 'currency': 'CAD', 'timezone': 'America/Vancouver', 'version': 1},
    ];
    return centerId;
  }

  /// An invitation to be a Center's Admin, as an Owner sent it. Returns its token.
  String addInvitation(String centerId, String email) {
    final token = 'token-${_nextToken++}';
    _invitations[token] = (centerId: centerId, email: email);
    return token;
  }

  /// Whether a person is an Admin of a Center.
  bool isAdmin(String centerId, String email) => _admins[centerId]?.contains(_personIdFor(email)) ?? false;

  String? _personIdFor(String email) => _logins[email]?.personId;

  Map<String, Object?>? _center(String centerId) =>
      _centers.values.expand((centers) => centers).where((center) => center['id'] == centerId).firstOrNull;

  Map<String, Object?> _centerAccess(Map<String, Object?> center) =>
      {'id': center['id'], 'name': center['name'], 'orgId': center['orgId'], 'roles': ['Admin']};

  Future<http.Response> _handle(http.Request request) async {
    final path = request.url.path.replaceFirst('/v1', '');
    requests.add('${request.method} $path');
    final claims = _claimsFrom(request.headers['authorization']);
    if (claims == null) return _json(401, {'message': 'Unauthorized'});
    final email = claims['email']!;
    final body = request.body.isEmpty ? null : jsonDecode(request.body) as Map<String, Object?>;
    if (body != null) (bodies['${request.method} $path'] ??= []).add(body);

    if (request.method == 'PUT' && path == '/me') {
      final login = _logins[email]!;
      final personId = login.personId ??= 'person-${_nextPerson++}';
      _people[personId] ??= {'personId': personId, 'name': body!['name'], 'email': email};
      return _json(201, _people[personId]!);
    }

    final personId = claims['personId'];
    if (personId == null) {
      return _json(403, {'message': "Sign up first, then refresh the login's tokens"});
    }

    if (request.method == 'GET' && path == '/me') {
      final organizations = _organizations.values
          .where((org) => org['ownerId'] == personId)
          .map((org) => {'id': org['id'], 'name': org['name'], 'roles': ['Owner']})
          .toList();
      return _json(200, {..._people[personId]!, 'organizations': organizations, 'centers': [
          for (final center in _centers.values.expand((centers) => centers))
            if (_admins[center['id']]?.contains(personId) ?? false) _centerAccess(center),
        ],
      });
    }
    if (request.method == 'POST' && path == '/organizations') {
      final center = {...body!['center'] as Map<String, Object?>, 'orgId': body['id'], 'version': 1};
      _organizations[body['id'] as String] = {'id': body['id'], 'name': body['name'], 'ownerId': personId};
      _centers[body['id'] as String] = [center];
      return _json(201, {'id': body['id'], 'name': body['name'], 'centers': [center]});
    }
    final centersPath = RegExp(r'^/organizations/([^/]+)/centers$').firstMatch(path);
    if (centersPath != null) {
      final orgId = centersPath.group(1)!;
      if (_organizations[orgId]?['ownerId'] != personId) {
        return _json(404, {'message': 'Organization not found'});
      }
      if (request.method == 'GET') {
        return _json(200, {
          'centers': [for (final center in _centers[orgId]!) {'id': center['id'], 'name': center['name']}],
        });
      }
      if (request.method == 'POST') {
        final center = {...body!, 'orgId': orgId, 'version': 1};
        _centers[orgId]!.add(center);
        return _json(201, center);
      }
    }
    final centerPath = RegExp(r'^/centers/([^/]+)(/.*)?$').firstMatch(path);
    if (centerPath != null) {
      return _centerRequest(request.method, centerPath.group(1)!, centerPath.group(2) ?? '', personId, email, body);
    }
    return _json(404, {'message': 'Not found'});
  }

  // Requests under /centers/{centerId}, with the same access rules as the API.
  http.Response _centerRequest(
    String method, String centerId, String rest, String personId, String email, Map<String, Object?>? body,
  ) {
    final center = _center(centerId);
    final notFound = _json(404, {'message': 'Center not found'});
    if (center == null) return notFound;
    final isOwner = _organizations[center['orgId']]?['ownerId'] == personId;
    final admins = _admins[centerId] ??= {};

    if (method == 'POST' && rest == '/invitations/accept') {
      final invitation = _invitations[body!['token']];
      if (invitation == null || invitation.centerId != centerId) {
        return _json(404, {'message': "This invitation doesn't exist, has expired or has already been used"});
      }
      if (invitation.email != email) {
        return _json(403, {
          'message': 'This invitation is for a different email address. Sign in with that one, confirmed, to accept it.',
        });
      }
      _invitations.remove(body['token']);
      admins.add(personId);
      return _json(200, _centerAccess(center));
    }
    if (!isOwner && !admins.contains(personId)) return notFound;

    if (method == 'GET' && rest == '') return _json(200, center);
    if (method == 'GET' && rest == '/admins') {
      return _json(200, {'admins': [for (final id in admins) _people[id]!]});
    }
    if (!isOwner) return notFound;
    if (method == 'POST' && rest == '/invitations') {
      final token = addInvitation(centerId, body!['email']! as String);
      return _json(201, {...body, 'token': token, 'centerId': centerId, 'expiresAt': '2026-01-08T00:00:00.000Z'});
    }
    final adminPath = RegExp(r'^/admins/([^/]+)$').firstMatch(rest);
    if (adminPath != null && method == 'PUT') {
      if (adminPath.group(1) != personId) return _json(400, {'message': 'Invite anyone else'});
      admins.add(personId);
      return _json(200, _people[personId]!);
    }
    if (adminPath != null && method == 'DELETE') {
      admins.remove(adminPath.group(1));
      return http.Response('', 204);
    }
    return _json(404, {'message': 'Not found'});
  }

  Map<String, String>? _claimsFrom(String? header) {
    if (header == null || !header.startsWith('Bearer ')) return null;
    return (jsonDecode(header.substring('Bearer '.length)) as Map<String, Object?>).cast<String, String>();
  }
}

http.Response _json(int status, Object body) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

class _Login {
  _Login(this.password);

  final String password;
  bool confirmed = false;
  bool totpEnabled = false;
  String? personId;
}

/// Cognito, as the app's [Auth] sees it. The confirmation code is always
/// 123456 and the authenticator app's code is always 654321.
class FakeAuth implements Auth {
  FakeAuth(this._backend);

  static const emailCode = '123456';
  static const authenticatorCode = '654321';

  final FakeBackend _backend;
  String? _signedIn;
  String? _pendingTotp;
  Map<String, String>? _token;

  /// How many times the app asked for fresh tokens.
  int refreshes = 0;

  @override
  Future<bool> isSignedIn() async => _signedIn != null;

  @override
  Future<void> signUp({required String email, required String password}) async {
    if (_backend._logins.containsKey(email)) throw const AuthFailure('An account with this email already exists');
    _backend._logins[email] = _Login(password);
  }

  @override
  Future<void> confirmSignUp({required String email, required String code}) async {
    if (code != emailCode) throw const AuthFailure('That code is wrong');
    _backend._logins[email]!.confirmed = true;
  }

  @override
  Future<SignInStep> signIn({required String email, required String password}) async {
    final login = _backend._logins[email];
    if (login == null || login.password != password || !login.confirmed) {
      throw const AuthFailure('Incorrect email or password');
    }
    if (login.totpEnabled) {
      _pendingTotp = email;
      return SignInStep.authenticatorCode;
    }
    _issueTokens(email);
    return SignInStep.done;
  }

  @override
  Future<SignInStep> confirmSignIn(String code) async {
    if (code != authenticatorCode) throw const AuthFailure('That code is wrong');
    _issueTokens(_pendingTotp!);
    return SignInStep.done;
  }

  @override
  Future<AuthenticatorSetup> startAuthenticatorSetup() async =>
      AuthenticatorSetup(secret: 'FAKESECRET', setupUri: Uri.parse('otpauth://totp/DC?secret=FAKESECRET'));

  @override
  Future<void> verifyAuthenticatorSetup(String code) async {
    if (code != authenticatorCode) throw const AuthFailure('That code is wrong');
    _backend._logins[_signedIn!]!.totpEnabled = true;
  }

  /// Whether the signed-in login has an authenticator app set up.
  bool get hasAuthenticatorApp => _backend._logins[_signedIn]?.totpEnabled ?? false;

  @override
  Future<String> idToken({bool forceRefresh = false}) async {
    if (forceRefresh) {
      refreshes++;
      _issueTokens(_signedIn!);
    }
    return jsonEncode(_token);
  }

  @override
  Future<void> signOut() async {
    _signedIn = null;
    _token = null;
  }

  // Like the pre-token trigger, a token carries the person ID only once the
  // login has signed up.
  void _issueTokens(String email) {
    _signedIn = email;
    final personId = _backend._personIdFor(email);
    _token = {'email': email, 'personId': ?personId};
  }
}
