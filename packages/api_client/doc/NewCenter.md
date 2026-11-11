# dc_api_client.model.NewCenter

## Load the model package
```dart
import 'package:dc_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A ULID created by the app, so a retried request can't create the record twice. Its time must be within 7 days of the server's clock.  | 
**name** | **String** |  | 
**currency** | [**Currency**](Currency.md) |  | 
**timezone** | **String** | The Center's IANA timezone, such as America/Vancouver. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


