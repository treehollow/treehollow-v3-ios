# 架构

采用如下图所示的MVVM架构。

![](https://mermaid.ink/svg/eyJjb2RlIjoiZ3JhcGggQlRcblx0Y2FjaGVbKENhY2hlKV1cblx0cmVtb3RlWyhSZW1vdGUpXVxuXHRyZXF1ZXN0W1JlcXVlc3RdXG5cdHJwW1JlcXVlc3QgUHVibGlzaGVyXVxuXHR2bVtWaWV3IE1vZGVsXVxuXHR2W1ZpZXddXG5cdFxuXHRjYWNoZSAtLT4gcmVxdWVzdFxuXHRyZXF1ZXN0IC0tPiB8dXBkYXRlfCBjYWNoZVxuXHRyZW1vdGUgLS0-IHJlcXVlc3Rcblx0cmVxdWVzdCAtLT4gcnAgLS0-IHxwdWJsaXNofCB2bSAtLT4gfGRhdGEgc291cmNlfCB2XG5cdHZtIC0tPiB8c3Vic2NyaWJlfCBycFxuXHR2IC0tPiB8aW50ZW50fCB2bVxuXHRcblx0c3ViZ3JhcGggTW9kZWxcblx0XHRjYWNoZVxuXHRcdHJlbW90ZVxuXHRcdHJlcXVlc3Rcblx0XHRycFxuXHRlbmRcblx0XG5cdHN0eWxlIE1vZGVsIGZpbGw6I2ZmZmZkZSxzdHJva2U6I2FhYWEzMzsiLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)

## Model

Model 部分的实现细节详见 [model-detail.md](model-detail.md)。

Model 部分主要进行缓存的管理，以及向服务器请求和发送数据。如上图所示，`Request` 进行具体的请求（查询缓存/进行HTTP请求），`Request Publisher` 对 `Request` 进行包装，并向 `View Model` 提供声明式的接口。

### 缓存管理

第三方依赖库：

- [Cache](https://github.com/hyperoslo/Cache.git)
- [Kingfisher](https://github.com/onevcat/Kingfisher.git)

### 请求和发送数据

我们为与树洞后端进行通信的类型定义了一个协议 `Request` 以规定接口，同时实现代码的高效复用。所有请求均可抽象成遵循此协议的类型。对于大部分请求而言，其请求过程均为请求数据 - 解析JSON - 数据转换 - 返回数据。针对这些请求，我们在 `Request` 的基础上规定了一个更高级的协议 `DefaultRequest`，并为其请求过程进行了默认的实现，大大减少了重复代码的编写。

### Publisher

针对声明式代码，利用原生 [Combine 框架](https://developer.apple.com/documentation/Combine)，我们使用 Publisher 对 Request 进行包装，降低管理异步事件的难度，同时更好地与 SwiftUI 的声明式风格融合。所有 Request 均可获取其 publisher，并在收到订阅时进行请求并返回结果。

## View

View 部分的实现细节详见 [view-detail.md](view-detail.md)。

### 数据流

View 部分的主要难点是数据流的实现。根据设计，本应用的数据流有以下几类：

- 整个应用的数据共享
- 父 View 与子 View 绑定数据
  - 父 View 作为唯一数据源
  - 子 View 作为（暂时的）唯一数据源
- 父 View 向子 View 传递只读数据

#### 整个应用的数据共享

由于采用了 SwiftUI 的生命周期（[App Essentials in SwiftUI](https://developer.apple.com/videos/play/wwdc2020/10037/)），我们在 `HollowApp` 中初始化一个唯一的、在所有 View 中共享的对象 ，储存需要在应用内共享的数据（如：用户的 token 是否过期），然后，通过向环境注入此对象来实现共享。

#### 父 View 与子 View 绑定数据 / 传递只读数据

当子 View 需要修改数据源（而本身并不拥有数据）时，用 `@Binding` 进行数据绑定；否则直接进行值的传递，此时父 View 中的数据对于子 View 来说是只读的。

#### 子 View 作为（暂时的）唯一数据源

有些情况下，子 View 需要更新父 View 中的数据，然而父 View 本身在这个过程中也可能会更新数据，从而导致很多问题。在某些情况下，我们需要在子 View 存在的时间里，将子 View 的数据作为唯一的数据源：子 View 中的数据不受父 View 的影响，并在自身的数据更新后，对父 View 的数据进行更新。

### 使用 UIKit

在本应用的实现中，有三种使用 UIKit 框架的情况：

- UIKit 的 `UIView` 或 `UIViewController` 作为 `View`，通过 `UIViewRepresentable` 和 `UIViewControllerRepresentable` 实现。
- 先将 `View` 用 `UIHostingController` 包装为 UIKit 的 `UIViewController`，在对其内部进行一定修改后，再用 `UIViewControllerRepresentable` 包装为 `View`。
- 直接使用 UIKit 的命令式代码实现视图的导航等操作。