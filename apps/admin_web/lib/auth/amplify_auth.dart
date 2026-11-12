import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'auth.dart';

/// The stage's user pool, as the deployed `config.json` gives it.
class CognitoConfig {
  const CognitoConfig({required this.region, required this.userPoolId, required this.appClientId});

  factory CognitoConfig.fromJson(Map<String, Object?> json) => CognitoConfig(
    region: json['region']! as String,
    userPoolId: json['userPoolId']! as String,
    appClientId: json['appClientId']! as String,
  );

  final String region;
  final String userPoolId;
  final String appClientId;
}

/// [Auth] through Amplify, signing in to the stage's Cognito user pool with SRP.
class AmplifyAuth implements Auth {
  AmplifyAuth._();

  static Future<AmplifyAuth> configure(CognitoConfig config) async {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(jsonEncode({
      'version': '1',
      'auth': {
        'aws_region': config.region,
        'user_pool_id': config.userPoolId,
        'user_pool_client_id': config.appClientId,
        'username_attributes': ['email'],
        'standard_required_attributes': ['email'],
        'user_verification_types': ['email'],
        'unauthenticated_identities_enabled': false,
        // Optional for everyone (#51).
        'mfa_configuration': 'OPTIONAL',
        'mfa_methods': ['TOTP'],
      },
    }));
    return AmplifyAuth._();
  }

  @override
  Future<bool> isSignedIn() async => (await Amplify.Auth.fetchAuthSession()).isSignedIn;

  @override
  Future<void> signUp({required String email, required String password}) => _explained(() async {
    await Amplify.Auth.signUp(
      username: email,
      password: password,
      options: SignUpOptions(userAttributes: {AuthUserAttributeKey.email: email}),
    );
  });

  @override
  Future<void> confirmSignUp({required String email, required String code}) => _explained(() async {
    await Amplify.Auth.confirmSignUp(username: email, confirmationCode: code);
  });

  @override
  Future<SignInStep> signIn({required String email, required String password}) => _explained(() async {
    final result = await Amplify.Auth.signIn(username: email, password: password);
    return _stepOf(result.nextStep.signInStep);
  });

  @override
  Future<SignInStep> confirmSignIn(String code) => _explained(() async {
    final result = await Amplify.Auth.confirmSignIn(confirmationValue: code);
    return _stepOf(result.nextStep.signInStep);
  });

  @override
  Future<AuthenticatorSetup> startAuthenticatorSetup() => _explained(() async {
    final details = await Amplify.Auth.setUpTotp();
    return AuthenticatorSetup(secret: details.sharedSecret, setupUri: details.getSetupUri(appName: 'DC Management'));
  });

  @override
  Future<void> verifyAuthenticatorSetup(String code) => _explained(() async {
    await Amplify.Auth.verifyTotpSetup(code);
    // Without this the app is set up but never asked for at sign-in.
    await Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey).updateMfaPreference(totp: MfaPreference.preferred);
  });

  @override
  Future<String> idToken({bool forceRefresh = false}) async {
    final session = await Amplify.Auth.fetchAuthSession(
      options: FetchAuthSessionOptions(forceRefresh: forceRefresh),
    ) as CognitoAuthSession;
    return session.userPoolTokensResult.value.idToken.raw;
  }

  @override
  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }

  SignInStep _stepOf(AuthSignInStep step) => switch (step) {
    AuthSignInStep.done => SignInStep.done,
    AuthSignInStep.confirmSignInWithTotpMfaCode => SignInStep.authenticatorCode,
    AuthSignInStep.confirmSignUp => throw const AuthFailure('Confirm your email first, with the code we sent'),
    _ => throw AuthFailure("This sign-in needs a step the app doesn't handle yet ($step)"),
  };

  // Turns Amplify's errors into messages the screens can show.
  Future<T> _explained<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    }
  }
}
