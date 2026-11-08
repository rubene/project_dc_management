# dc_api_client.api.DefaultApi

## Load the API package
```dart
import 'package:dc_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getHealth**](DefaultApi.md#gethealth) | **GET** /health | Check that the API is up


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

