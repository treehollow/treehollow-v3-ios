# /Model/Net

## Grouping Principle

- The files are grouped by the API group that backend provides.

## Design and Naming Principle

- Each file with name `XXXRequest` represents a single request, otherwise represents the data for the naming content. For example, the file `DeviceListRequest.swift` describes the **request configuration**, **request result** and the **request** itself of requesting currently online devices, and `DeviceInformation.swift` describes the **information of the device**.

- Each `XXXRequest` file might consist of some of the three  `struct` below and if necessary, some other types:
    - `XXXRequestConfiguration` - configuration for the request
    - `XXXRequestResult` - the result received from the server
    - `XXXRequest` - performs the request tasks and provides APIs to the `ViewModel`, **conforming to protocol `Request`**.
    
    Noted that for some request that only take one parameter for configuration, the `XXXRequestConfiguration` is not declared. And the type for some request that take the same configuration or result parameters with one other request is also not declared. Instead, they keep the same naming format using `typealias`.

- Specifically, the nested enum `ResultType` inside `XXXRequestResult` represents the code that server returns, which can be helpful to identify what the error code means. Although a large proportion of them only indicates success with `0` and failure with negative code, we still declare them in case of API changes. For requests that themselves don't have a request result type, the enum is named `XXXRequestResultType`.
