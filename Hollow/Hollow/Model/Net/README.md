# /Model/Net

The requests to communicate with backend and return the data received.

## Design

### Architecture

A request is defined by four types:
- configuration: the information needed to perform a request.
- result: the result received from the server.
- result data: the data returned to the callers.
- error: possibile errors occured during the request.

The requests are responsible for:
1. receive configuration from the caller
2. communicate with the server to fetch the result
3. convert the result to the data
4. return the data to the caller

### Data structure

Two protocols are defined to provide a set of uniform, concise APIs:

-  `protocol Request` - the request itself
-  `protocol RequestError` - the possible error during the request

To better reuse our code, some additional protocols and types are defined to implement default behaviours:

- `protocol DefaultRequest` -  requests that share some same attributes, applied to almost all requests
- `protocol DefaultRequestResult` - request result with `code` and `msg` constrains
- `enum DefaultRequestError` - the default request error, covering common error cases

Documentation for these protocols and types is available in the source code.

> Use `enum` for error, and use `struct` or `enum` for other types.

## Naming Principle

- Each file should be named  `XXXRequest`, which represents a single request.

- Each `XXXRequest` file might consist of some of the four  `struct` below, with following format:
    - `XXXRequestConfiguration`
    - `XXXRequestResult`
    - `XXXRequestResultData`
    - `XXXRequest`
