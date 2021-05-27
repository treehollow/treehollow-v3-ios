# View 实现细节

## 数据流

### 所有 View 共享数据

定义一个类型 `AppModel`，初始化单例 `shared`，在 `HollowApp` 中使用 `@StateObject` 监测其变化，即可实现应用状态的共享。

```swift
struct HollowApp: App {
    ...
    @StateObject var appModel = AppModel.shared
    ...
}
```

### 子 View 作为（暂时的）唯一数据源

在 `HollowDetailView` 中，我们希望将其获取的 `postData` 作为唯一的数据源对传入的数据进行覆盖。其关系如下：

![](https://mermaid.ink/svg/eyJjb2RlIjoiZ3JhcGggVERcblx0YmluZGluZ1tCaW5kaW5nIGRhdGFdXG5cdGRhdGFbRGF0YV1cblx0cltSZXF1ZXN0XVxuXHR2bVtWaWV3IE1vZGVsXVxuXHR2W1ZpZXddXG5cdHB2W1BhcmVudCBWaWV3XVxuXHRcblx0dm0gLS0-IHxwZXJmb3JtfCByIC0tPiB8dXBkYXRlfCBkYXRhIC0tPiB8b24gY2hhbmdlLCB1cGRhdGV8IGJpbmRpbmdcblx0cHYgLS0-IGJpbmRpbmdcblx0ZGF0YSAtLT4gfHJlZmxlY3Qgb258IHZcblx0YmluZGluZyAtLT4gfGluaXRpYWxpemV8IGRhdGEiLCJtZXJtYWlkIjp7fSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)

在其 View Model 中进行如下的实现：

```swift
class HollowDetailStore: ObservableObject, ... {
    var bindingPostWrapper: Binding<PostDataWrapper>
    @Published var postDataWrapper: PostDataWrapper
    
    init(bindingPostWrapper: Binding<PostDataWrapper>, ...) {
        self.postDataWrapper = bindingPostWrapper.wrappedValue
        self.bindingPostWrapper = bindingPostWrapper
        
        $postDataWrapper
            .receive(on: DispatchQueue.main)
            .assign(to: \.bindingPostWrapper.wrappedValue, on: self)
            .store(...)
        ...
    }
}
```

变量 `bindingPostWrapper` 为与上层 View 进行绑定的数据，而 `postDataWrapper` 为 `HollowDetailView` 获取并使用的数据。使用上层传入的数据对 `postDataWrapper` 进行初始化，子 View 使用 `postDataWrapper` 作为数据源；当 `postDataWrapper` 被更新时，更新 `bindingPostData`。这一步通过 `@Published` 变量作为 publisher 的 `projectedValue` 进行。
