# dc_api_client.model.CenterChange

## Load the model package
```dart
import 'package:dc_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**changeId** | **String** | A ULID created by the app, so a retried request can't create the record twice. Its time must be within 7 days of the server's clock.  | 
**expectedVersion** | **int** | The profile's version the change was made against. | 
**timezone** | **String** | The Center's new IANA timezone, such as America/Toronto. | 
**reason** | **String** | Why the change was made, kept in the history. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


