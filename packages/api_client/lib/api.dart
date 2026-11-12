//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/default_api.dart';

part 'model/admin.dart';
part 'model/admin_list.dart';
part 'model/center_access.dart';
part 'model/center_change.dart';
part 'model/center_history.dart';
part 'model/center_list.dart';
part 'model/center_profile.dart';
part 'model/center_summary.dart';
part 'model/center_version.dart';
part 'model/currency.dart';
part 'model/error.dart';
part 'model/health.dart';
part 'model/health_unavailable.dart';
part 'model/invitable_role.dart';
part 'model/invitation.dart';
part 'model/invitation_acceptance.dart';
part 'model/me.dart';
part 'model/new_center.dart';
part 'model/new_invitation.dart';
part 'model/new_organization.dart';
part 'model/organization.dart';
part 'model/organization_access.dart';
part 'model/person.dart';
part 'model/sign_up.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
