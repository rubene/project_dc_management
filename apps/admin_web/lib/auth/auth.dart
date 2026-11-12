/// Logging in, as the screens need it. Cognito handles login only; Roles come
/// from the API. [AmplifyAuth] is the real one, and tests use a fake.
abstract class Auth {
  Future<bool> isSignedIn();

  /// Creates a login. Cognito then emails a code to confirm the address.
  Future<void> signUp({required String email, required String password});

  Future<void> confirmSignUp({required String email, required String code});

  Future<SignInStep> signIn({required String email, required String password});

  /// Finishes signing in with the code from the person's authenticator app.
  Future<SignInStep> confirmSignIn(String code);

  /// Starts adding an authenticator app, which is optional for everyone.
  Future<AuthenticatorSetup> startAuthenticatorSetup();

  /// Finishes adding the app with a code it shows, and turns it on for
  /// every later sign-in.
  Future<void> verifyAuthenticatorSetup(String code);

  /// The current ID token, for the API. [forceRefresh] gets a new one, as
  /// after signing up, when only new tokens carry the person ID.
  Future<String> idToken({bool forceRefresh = false});

  Future<void> signOut();
}

enum SignInStep {
  done,

  /// The login has an authenticator app, and its code is needed.
  authenticatorCode,
}

class AuthenticatorSetup {
  const AuthenticatorSetup({required this.secret, required this.setupUri});

  /// The key to type into an authenticator app by hand.
  final String secret;

  /// The `otpauth://` link an authenticator app can scan as a QR code.
  final Uri setupUri;
}

/// Something went wrong that the person can fix, with a message for them.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
