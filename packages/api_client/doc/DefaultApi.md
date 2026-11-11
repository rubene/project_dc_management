# dc_api_client.api.DefaultApi

## Load the API package
```dart
import 'package:dc_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addCenter**](DefaultApi.md#addcenter) | **POST** /organizations/{orgId}/centers | Add a Center to an Organization the signed-in person owns
[**createOrganization**](DefaultApi.md#createorganization) | **POST** /organizations | Create an Organization with its first Center, owned by the signed-in person
[**getHealth**](DefaultApi.md#gethealth) | **GET** /health | Check that the API is up
[**getMe**](DefaultApi.md#getme) | **GET** /me | The signed-in person
[**listCenters**](DefaultApi.md#listcenters) | **GET** /organizations/{orgId}/centers | The Centers of an Organization the signed-in person owns
[**signUp**](DefaultApi.md#signup) | **PUT** /me | Sign up the person behind the current login


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

