# Model 实现细节

## Request 协议的设计

### `protocol Request`

`Request` 协议的规定如下：

```swift
protocol Request {
    associatedtype Configuration
    associatedtype Result
    associatedtype ResultData
    associatedtype Error: RequestError

    var configuration: Configuration { get }
    init(configuration: Configuration)
    func performRequest(completion: @escaping (ResultData?, Error?) -> Void)
}
```

每个 `Request` 由四个类型定义：

- Configuration：从外部传入的参数
- Result：服务器返回的数据，作为解析JSON的模版
- ResultData：对 `Result` 进行一定的处理，向外部返回的最终结果
- Error：请求过程中出现的错误（遵循 `RequestError` 协议）

协议规定的两个接口为 `init` 和 `performRequest`，分别对应输入与输出。

### `protocol DefaultRequest`

为了实现代码复用，针对能够利用 `Decodable` 的类型作为模版解析 JSON 的请求，定义了另外一个依赖于 `Request` 的协议 `DefaultRequest`，其 `Result` 和 `Error` 有进一步的限制。绝大多数的请求均可遵循这一更高级的协议。

```swift
protocol DefaultRequest: Request where Error == DefaultRequestError, Result: DefaultRequestResult
```

我们可以对 `performRequest` 进行默认实现：

```swift
internal func performRequest(
    urlBase: [String],
    urlPath: String,
    parameters: [String : Any]? = nil,
    headers: HTTPHeaders? = nil,
    method: HTTPMethod,
    transformer: @escaping (Result) -> ResultData?,
    completion: @escaping (ResultData?, DefaultRequestError?) -> Void
)
```

使用 `protocol` 的优势在这里体现了出来：我们可以对协议相关的函数进行默认的实现，而无需知道类型的具体信息。在具体的类中，只需要提供以上参数，即可完成请求。例如，在 `LoginRequest` 中：

```swift
func performRequest(completion: @escaping (LoginRequestResultData?, Error?) -> Void) {
    let parameters = [...]
    let urlPath = ...
    performRequest(
        urlBase: self.configuration.apiRoot,
        urlPath: urlPath,
        parameters: parameters,
        method: .post,
        transformer: { result in
            guard let token = result.token, let uuid = result.uuid else { return nil }
            return LoginRequestResultData(token: token, uuid: uuid, message: result.msg)
        },
        completion: completion
    )
}
```

便可自动完成结果的解析、错误的处理及返回等步骤。

## Publisher

我们利用 Publisher 来处理异步事件。

单个  `Request` 可通过其计算变量 `publisher` 获取其 publisher：

```swift
var publisher: RequestPublisher<Self> {
    return RequestPublisher(configuration: configuration)
}
```

而针对多个同时进行的异步事件（如加载图片、加载引用），可以通过 `Request` 协议的一个默认实现来获取一个整合的 publisher：

```swift
static func publisher(for requests: [Self], retries: Int = 0) -> AnyPublisher<(Int, OptionalOutput<ResultData, Error>), Never>?
```

其中，`OptionalOutput` 是一个以成功时的结果与失败时的错误作为 associated value 的 `enum`：

```swift
enum OptionalOutput<R, E: Error> {
    case success(R)
    case failure(E)
}
```

在这个函数中，我们对每个 Request 的 publisher 作一定的变换：将成功的数据变换成 `OptionalOutput` 的 `success`，忽略 publisher 的 `Failure`，并将其变换为 `OptionalOutput` 的 `failure`；再将请求的序号与输出放在一个 tuple 中，最终输出。

> 在这里，忽略 `Failure` 的原因是，如果保留 `Failure`， 当某个请求失败， `Failure` 出现时，整个 publisher 的输出立刻终止，我们就不能获取其他请求的结果，而这显然并不是我们想要的。

然后，我们将所有的 publisher 整合为一个 publisher，就可以实现，在同时进行多个异步请求的同时，获取每个请求的细节（如错误信息）：

```swift
let requests: [PostDetailRequest] = ...
PostDetailRequest.publisher(for: requests)?
    .sink(receiveValue: { index, output in
        switch output {
        case .failure(let error):
          // 处理第 index 个请求的错误
        case .success(let postData):
          // 处理第 index 个请求的结果
        }
    })
    .store(...)
```

## 处理相同结果的请求

在树洞后端的 API 中，有一些 API 的结果是一样的（因此 `ResultData` 和 `Error` 的类型是一样的，对外接口除了 `Configuration` 也是一样的，处理其结果的 View Model 的结构也是类似的）。为了重用 View Model 的代码，我们为这些 Request 制定了一个新的 Request，其 `Configuration` 类型为一个 `enum`。例如，`PostListRequestGroupConfiguration`：

```swift
enum PostListRequestGroupConfiguration {
    case postList(PostListRequestConfiguration)
    case search(SearchRequestConfiguration)
    case searchTrending(SearchRequestConfiguration)
    case attentionList(AttentionListRequestConfiguration)
    case attentionListSearch(AttentionListSearchRequestConfiguration)
    case wander(RandomListRequestConfiguration)
}
```

在 View Model 中，传入对应的 `configuration` 即可。