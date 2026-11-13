# dc_api_client.api.DefaultApi

## Load the API package
```dart
import 'package:dc_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptInvitation**](DefaultApi.md#acceptinvitation) | **POST** /centers/{centerId}/invitations/accept | Accept an invitation to a Center and take its Role there
[**addCenter**](DefaultApi.md#addcenter) | **POST** /organizations/{orgId}/centers | Add a Center to an Organization the signed-in person owns
[**appointSelfAsAdmin**](DefaultApi.md#appointselfasadmin) | **PUT** /centers/{centerId}/admins/{personId} | Make the signed-in Owner an Admin of one of their Centers
[**changeCenter**](DefaultApi.md#changecenter) | **PATCH** /centers/{centerId} | Change a Center's timezone, keeping its history
[**createInvitation**](DefaultApi.md#createinvitation) | **POST** /centers/{centerId}/invitations | Invite a person to a Center, for an Owner of its Organization
[**createOrganization**](DefaultApi.md#createorganization) | **POST** /organizations | Create an Organization with its first Center, owned by the signed-in person
[**getCenter**](DefaultApi.md#getcenter) | **GET** /centers/{centerId} | A Center's profile, for an Owner of its Organization or an Admin of the Center
[**getCenterHistory**](DefaultApi.md#getcenterhistory) | **GET** /centers/{centerId}/history | Every version of a Center's profile, oldest first
[**getHealth**](DefaultApi.md#gethealth) | **GET** /health | Check that the API is up
[**getMe**](DefaultApi.md#getme) | **GET** /me | The signed-in person
[**listAdmins**](DefaultApi.md#listadmins) | **GET** /centers/{centerId}/admins | A Center's Admins, for an Owner of its Organization or an Admin of the Center
[**listCenters**](DefaultApi.md#listcenters) | **GET** /organizations/{orgId}/centers | The Centers of an Organization the signed-in person owns
[**removeAdmin**](DefaultApi.md#removeadmin) | **DELETE** /centers/{centerId}/admins/{personId} | Take the Admin Role away from a person at a Center
[**signUp**](DefaultApi.md#signup) | **PUT** /me | Sign up the person behind the current login


# **acceptInvitation**
> CenterAccess acceptInvitation(centerId, invitationAcceptance)

Accept an invitation to a Center and take its Role there

Accepting the same invitation again returns the same result, so the app can retry. 

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final centerId = centerId_example; // String | 
final invitationAcceptance = InvitationAcceptance(); // InvitationAcceptance | 

try {
    final result = api_instance.acceptInvitation(centerId, invitationAcceptance);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->acceptInvitation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **centerId** | **String**|  | 
 **invitationAcceptance** | [**InvitationAcceptance**](InvitationAcceptance.md)|  | 

### Return type

[**CenterAccess**](CenterAccess.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addCenter**
> CenterProfile addCenter(orgId, newCenter)

Add a Center to an Organization the signed-in person owns

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final orgId = orgId_example; // String | 
final newCenter = NewCenter(); // NewCenter | 

try {
    final result = api_instance.addCenter(orgId, newCenter);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->addCenter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **orgId** | **String**|  | 
 **newCenter** | [**NewCenter**](NewCenter.md)|  | 

### Return type

[**CenterProfile**](CenterProfile.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **appointSelfAsAdmin**
> Admin appointSelfAsAdmin(centerId, personId)

Make the signed-in Owner an Admin of one of their Centers

`personId` must be the signed-in Owner's own. Anyone else becomes an Admin by accepting an invitation. Appointing an Owner who's already an Admin changes nothing. 

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final centerId = centerId_example; // String | 
final personId = personId_example; // String | 

try {
    final result = api_instance.appointSelfAsAdmin(centerId, personId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->appointSelfAsAdmin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **centerId** | **String**|  | 
 **personId** | **String**|  | 

### Return type

[**Admin**](Admin.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **changeCenter**
> CenterProfile changeCenter(centerId, centerChange)

Change a Center's timezone, keeping its history

Records already saved keep the dates they were saved with. A retry of the same change gets the original result back. A change redone after a 409 is a new change and needs a new `changeId`. 

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final centerId = centerId_example; // String | 
final centerChange = CenterChange(); // CenterChange | 

try {
    final result = api_instance.changeCenter(centerId, centerChange);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->changeCenter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **centerId** | **String**|  | 
 **centerChange** | [**CenterChange**](CenterChange.md)|  | 

### Return type

[**CenterProfile**](CenterProfile.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInvitation**
> Invitation createInvitation(centerId, newInvitation)

Invite a person to a Center, for an Owner of its Organization

The response holds the invitation's token, the only time it's shown. The app sends it to the person as a link. Only a login with the invitation's email can accept it, within 7 days. Sending the same request again makes another invitation, and an unused one expires. 

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final centerId = centerId_example; // String | 
final newInvitation = NewInvitation(); // NewInvitation | 

try {
    final result = api_instance.createInvitation(centerId, newInvitation);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->createInvitation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **centerId** | **String**|  | 
 **newInvitation** | [**NewInvitation**](NewInvitation.md)|  | 

### Return type

[**Invitation**](Invitation.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createOrganization**
> Organization createOrganization(newOrganization)

Create an Organization with its first Center, owned by the signed-in person

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final newOrganization = NewOrganization(); // NewOrganization | 

try {
    final result = api_instance.createOrganization(newOrganization);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->createOrganization: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **newOrganization** | [**NewOrganization**](NewOrganization.md)|  | 

### Return type

[**Organization**](Organization.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCenter**
> CenterProfile getCenter(centerId)

A Center's profile, for an Owner of its Organization or an Admin of the Center

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final centerId = centerId_example; // String | 

try {
    final result = api_instance.getCenter(centerId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getCenter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **centerId** | **String**|  | 

### Return type

[**CenterProfile**](CenterProfile.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCenterHistory**
> CenterHistory getCenterHistory(centerId)

Every version of a Center's profile, oldest first

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final centerId = centerId_example; // String | 

try {
    final result = api_instance.getCenterHistory(centerId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getCenterHistory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **centerId** | **String**|  | 

### Return type

[**CenterHistory**](CenterHistory.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHealth**
> Health getHealth()

Check that the API is up

### Example
```dart
import 'package:dc_api_client/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.getHealth();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getHealth: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Health**](Health.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMe**
> Me getMe()

The signed-in person

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();

try {
    final result = api_instance.getMe();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Me**](Me.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAdmins**
> AdminList listAdmins(centerId)

A Center's Admins, for an Owner of its Organization or an Admin of the Center

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final centerId = centerId_example; // String | 

try {
    final result = api_instance.listAdmins(centerId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listAdmins: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **centerId** | **String**|  | 

### Return type

[**AdminList**](AdminList.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCenters**
> CenterList listCenters(orgId)

The Centers of an Organization the signed-in person owns

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final orgId = orgId_example; // String | 

try {
    final result = api_instance.listCenters(orgId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listCenters: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **orgId** | **String**|  | 

### Return type

[**CenterList**](CenterList.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeAdmin**
> removeAdmin(centerId, personId)

Take the Admin Role away from a person at a Center

For an Owner of the Center's Organization, who may remove themselves. It takes effect on the person's next request, and cancels the person's invitations to the Center that they haven't accepted. Removing someone who isn't an Admin changes nothing else, so the app can retry. 

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final centerId = centerId_example; // String | 
final personId = personId_example; // String | 

try {
    api_instance.removeAdmin(centerId, personId);
} catch (e) {
    print('Exception when calling DefaultApi->removeAdmin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **centerId** | **String**|  | 
 **personId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signUp**
> Person signUp(signUp)

Sign up the person behind the current login

### Example
```dart
import 'package:dc_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: cognito
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('cognito').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final signUp = SignUp(); // SignUp | 

try {
    final result = api_instance.signUp(signUp);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->signUp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signUp** | [**SignUp**](SignUp.md)|  | 

### Return type

[**Person**](Person.md)

### Authorization

[cognito](../README.md#cognito)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

