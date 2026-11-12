//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class DefaultApi {
  DefaultApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Accept an invitation to a Center and take its Role there
  ///
  /// Accepting the same invitation again returns the same result, so the app can retry. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [InvitationAcceptance] invitationAcceptance (required):
  Future<Response> acceptInvitationWithHttpInfo(String centerId, InvitationAcceptance invitationAcceptance,) async {
    // ignore: prefer_const_declarations
    final path = r'/centers/{centerId}/invitations/accept'
      .replaceAll('{centerId}', centerId);

    // ignore: prefer_final_locals
    Object? postBody = invitationAcceptance;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Accept an invitation to a Center and take its Role there
  ///
  /// Accepting the same invitation again returns the same result, so the app can retry. 
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [InvitationAcceptance] invitationAcceptance (required):
  Future<CenterAccess?> acceptInvitation(String centerId, InvitationAcceptance invitationAcceptance,) async {
    final response = await acceptInvitationWithHttpInfo(centerId, invitationAcceptance,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CenterAccess',) as CenterAccess;
    
    }
    return null;
  }

  /// Add a Center to an Organization the signed-in person owns
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] orgId (required):
  ///
  /// * [NewCenter] newCenter (required):
  Future<Response> addCenterWithHttpInfo(String orgId, NewCenter newCenter,) async {
    // ignore: prefer_const_declarations
    final path = r'/organizations/{orgId}/centers'
      .replaceAll('{orgId}', orgId);

    // ignore: prefer_final_locals
    Object? postBody = newCenter;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Add a Center to an Organization the signed-in person owns
  ///
  /// Parameters:
  ///
  /// * [String] orgId (required):
  ///
  /// * [NewCenter] newCenter (required):
  Future<CenterProfile?> addCenter(String orgId, NewCenter newCenter,) async {
    final response = await addCenterWithHttpInfo(orgId, newCenter,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CenterProfile',) as CenterProfile;
    
    }
    return null;
  }

  /// Make the signed-in Owner an Admin of one of their Centers
  ///
  /// `personId` must be the signed-in Owner's own. Anyone else becomes an Admin by accepting an invitation. Appointing an Owner who's already an Admin changes nothing. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [String] personId (required):
  Future<Response> appointSelfAsAdminWithHttpInfo(String centerId, String personId,) async {
    // ignore: prefer_const_declarations
    final path = r'/centers/{centerId}/admins/{personId}'
      .replaceAll('{centerId}', centerId)
      .replaceAll('{personId}', personId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Make the signed-in Owner an Admin of one of their Centers
  ///
  /// `personId` must be the signed-in Owner's own. Anyone else becomes an Admin by accepting an invitation. Appointing an Owner who's already an Admin changes nothing. 
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [String] personId (required):
  Future<Admin?> appointSelfAsAdmin(String centerId, String personId,) async {
    final response = await appointSelfAsAdminWithHttpInfo(centerId, personId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Admin',) as Admin;
    
    }
    return null;
  }

  /// Change a Center's timezone, keeping its history
  ///
  /// Records already saved keep the dates they were saved with. A retry of the same change gets the original result back. A change redone after a 409 is a new change and needs a new `changeId`. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [CenterChange] centerChange (required):
  Future<Response> changeCenterWithHttpInfo(String centerId, CenterChange centerChange,) async {
    // ignore: prefer_const_declarations
    final path = r'/centers/{centerId}'
      .replaceAll('{centerId}', centerId);

    // ignore: prefer_final_locals
    Object? postBody = centerChange;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Change a Center's timezone, keeping its history
  ///
  /// Records already saved keep the dates they were saved with. A retry of the same change gets the original result back. A change redone after a 409 is a new change and needs a new `changeId`. 
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [CenterChange] centerChange (required):
  Future<CenterProfile?> changeCenter(String centerId, CenterChange centerChange,) async {
    final response = await changeCenterWithHttpInfo(centerId, centerChange,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CenterProfile',) as CenterProfile;
    
    }
    return null;
  }

  /// Invite a person to a Center, for an Owner of its Organization
  ///
  /// The response holds the invitation's token, the only time it's shown. The app sends it to the person as a link. Only a login with the invitation's email can accept it, within 7 days. Sending the same request again makes another invitation, and an unused one expires. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [NewInvitation] newInvitation (required):
  Future<Response> createInvitationWithHttpInfo(String centerId, NewInvitation newInvitation,) async {
    // ignore: prefer_const_declarations
    final path = r'/centers/{centerId}/invitations'
      .replaceAll('{centerId}', centerId);

    // ignore: prefer_final_locals
    Object? postBody = newInvitation;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Invite a person to a Center, for an Owner of its Organization
  ///
  /// The response holds the invitation's token, the only time it's shown. The app sends it to the person as a link. Only a login with the invitation's email can accept it, within 7 days. Sending the same request again makes another invitation, and an unused one expires. 
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [NewInvitation] newInvitation (required):
  Future<Invitation?> createInvitation(String centerId, NewInvitation newInvitation,) async {
    final response = await createInvitationWithHttpInfo(centerId, newInvitation,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Invitation',) as Invitation;
    
    }
    return null;
  }

  /// Create an Organization with its first Center, owned by the signed-in person
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [NewOrganization] newOrganization (required):
  Future<Response> createOrganizationWithHttpInfo(NewOrganization newOrganization,) async {
    // ignore: prefer_const_declarations
    final path = r'/organizations';

    // ignore: prefer_final_locals
    Object? postBody = newOrganization;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Create an Organization with its first Center, owned by the signed-in person
  ///
  /// Parameters:
  ///
  /// * [NewOrganization] newOrganization (required):
  Future<Organization?> createOrganization(NewOrganization newOrganization,) async {
    final response = await createOrganizationWithHttpInfo(newOrganization,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Organization',) as Organization;
    
    }
    return null;
  }

  /// A Center's profile, for an Owner of its Organization or an Admin of the Center
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  Future<Response> getCenterWithHttpInfo(String centerId,) async {
    // ignore: prefer_const_declarations
    final path = r'/centers/{centerId}'
      .replaceAll('{centerId}', centerId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// A Center's profile, for an Owner of its Organization or an Admin of the Center
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  Future<CenterProfile?> getCenter(String centerId,) async {
    final response = await getCenterWithHttpInfo(centerId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CenterProfile',) as CenterProfile;
    
    }
    return null;
  }

  /// Every version of a Center's profile, oldest first
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  Future<Response> getCenterHistoryWithHttpInfo(String centerId,) async {
    // ignore: prefer_const_declarations
    final path = r'/centers/{centerId}/history'
      .replaceAll('{centerId}', centerId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Every version of a Center's profile, oldest first
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  Future<CenterHistory?> getCenterHistory(String centerId,) async {
    final response = await getCenterHistoryWithHttpInfo(centerId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CenterHistory',) as CenterHistory;
    
    }
    return null;
  }

  /// Check that the API is up
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getHealthWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/health';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Check that the API is up
  Future<Health?> getHealth() async {
    final response = await getHealthWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Health',) as Health;
    
    }
    return null;
  }

  /// The signed-in person
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getMeWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/me';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// The signed-in person
  Future<Me?> getMe() async {
    final response = await getMeWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Me',) as Me;
    
    }
    return null;
  }

  /// A Center's Admins, for an Owner of its Organization or an Admin of the Center
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  Future<Response> listAdminsWithHttpInfo(String centerId,) async {
    // ignore: prefer_const_declarations
    final path = r'/centers/{centerId}/admins'
      .replaceAll('{centerId}', centerId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// A Center's Admins, for an Owner of its Organization or an Admin of the Center
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  Future<AdminList?> listAdmins(String centerId,) async {
    final response = await listAdminsWithHttpInfo(centerId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminList',) as AdminList;
    
    }
    return null;
  }

  /// The Centers of an Organization the signed-in person owns
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] orgId (required):
  Future<Response> listCentersWithHttpInfo(String orgId,) async {
    // ignore: prefer_const_declarations
    final path = r'/organizations/{orgId}/centers'
      .replaceAll('{orgId}', orgId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// The Centers of an Organization the signed-in person owns
  ///
  /// Parameters:
  ///
  /// * [String] orgId (required):
  Future<CenterList?> listCenters(String orgId,) async {
    final response = await listCentersWithHttpInfo(orgId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CenterList',) as CenterList;
    
    }
    return null;
  }

  /// Take the Admin Role away from a person at a Center
  ///
  /// For an Owner of the Center's Organization, who may remove themselves. It takes effect on the person's next request, and cancels the person's invitations to the Center that they haven't accepted. Removing someone who isn't an Admin changes nothing else, so the app can retry. 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [String] personId (required):
  Future<Response> removeAdminWithHttpInfo(String centerId, String personId,) async {
    // ignore: prefer_const_declarations
    final path = r'/centers/{centerId}/admins/{personId}'
      .replaceAll('{centerId}', centerId)
      .replaceAll('{personId}', personId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Take the Admin Role away from a person at a Center
  ///
  /// For an Owner of the Center's Organization, who may remove themselves. It takes effect on the person's next request, and cancels the person's invitations to the Center that they haven't accepted. Removing someone who isn't an Admin changes nothing else, so the app can retry. 
  ///
  /// Parameters:
  ///
  /// * [String] centerId (required):
  ///
  /// * [String] personId (required):
  Future<void> removeAdmin(String centerId, String personId,) async {
    final response = await removeAdminWithHttpInfo(centerId, personId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Sign up the person behind the current login
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [SignUp] signUp (required):
  Future<Response> signUpWithHttpInfo(SignUp signUp,) async {
    // ignore: prefer_const_declarations
    final path = r'/me';

    // ignore: prefer_final_locals
    Object? postBody = signUp;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Sign up the person behind the current login
  ///
  /// Parameters:
  ///
  /// * [SignUp] signUp (required):
  Future<Person?> signUp(SignUp signUp,) async {
    final response = await signUpWithHttpInfo(signUp,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Person',) as Person;
    
    }
    return null;
  }
}
