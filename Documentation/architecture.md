# 架构

采用如下图所示的MVVM架构。

![](https://mermaid.ink/svg/eyJjb2RlIjoiZ3JhcGggQlRcblx0Y2FjaGVbKENhY2hlKV1cblx0cmVtb3RlWyhSZW1vdGUpXVxuXHRyZXF1ZXN0W1JlcXVlc3RdXG5cdHJwW1JlcXVlc3QgUHVibGlzaGVyXVxuXHR2bVtWaWV3IE1vZGVsXVxuXHR2W1ZpZXddXG5cdFxuXHRjYWNoZSAtLT4gcmVxdWVzdFxuXHRyZXF1ZXN0IC0tPiB8dXBkYXRlfCBjYWNoZVxuXHRyZW1vdGUgLS0-IHJlcXVlc3Rcblx0cmVxdWVzdCAtLT4gcnAgLS0-IHxwdWJsaXNofCB2bSAtLT4gfGRhdGEgc291cmNlfCB2XG5cdHZtIC0tPiB8c3Vic2NyaWJlfCBycFxuXHR2IC0tPiB8aW50ZW50fCB2bVxuXHRcblx0c3ViZ3JhcGggTW9kZWxcblx0XHRjYWNoZVxuXHRcdHJlbW90ZVxuXHRcdHJlcXVlc3Rcblx0XHRycFxuXHRlbmRcblx0XG5cdHN0eWxlIE1vZGVsIGZpbGw6I2ZmZmZkZSxzdHJva2U6I2FhYWEzMzsiLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)

## Model

Model部分主要进行缓存的管理，以及向服务器请求和发送数据。如上图所示，`Request` 进行具体的请求（查询缓存/进行HTTP请求），`Request Publisher` 对 `Request` 进行包装，并向 `ViewModel` 提供声明式的接口。

- 缓存管理

  第三方依赖库：

  - [Cache](https://github.com/hyperoslo/Cache.git)
  - [Kingfisher](https://github.com/onevcat/Kingfisher.git)

- 请求和发送数据

  我们为与树洞后端进行通信的类型定义了一个协议 `Request` 以规定接口，同时实现代码的高效复用。其规定如下：

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
  - Error：请求过程中出现的错误

  协议规定的两个接口为 `init` 和 `performRequest`，分别对应输入与输出。

  为了实现代码复用，针对能够利用 `Decodable` 的类型作为模版解析 JSON 的请求，定义了另外一个依赖于 `Request` 的协议 `DefaultRequest`，其 `Result` 和 `Error` 有进一步的限制。同时相应的，我们可以对 `performRequest` 进行默认实现。绝大多数的请求均可遵循这一更高级的协议。

- Publisher

  针对声明式代码，利用原生 [Combine 框架](https://developer.apple.com/documentation/Combine)，我们使用 Publisher 对 Request 进行包装，降低管理异步事件的难度，同时更好地与 SwiftUI 的声明式风格融合。

  单个  `Request` 可通过其计算变量 `publisher` 获取其 publisher。而针对多个同时进行的异步事件（如加载图片、加载引用），可以通过 `Request` 协议的一个默认实现来获取一个整合的 publisher：

  ```swift
  static func publisher(for requests: [Self]) -> AnyPublisher<(Int, OptionalOutput<ResultData, Error>), Never>?
  ```

  通过这个整合后的 publisher，我们就可以在同时进行多个异步请求的同时，获取每个请求的细节（如错误信息）：

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

  这在传统的依赖回调函数的代码中的实现是非常复杂的。
