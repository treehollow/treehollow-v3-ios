# View 实现细节

## 数据流

### 所有 View 共享数据的实现

由于采用了 SwiftUI 的生命周期（[App essentials in SwiftUI](https://developer.apple.com/videos/play/wwdc2020/10037/)），我们在 `HollowApp` 中初始化一个唯一的、在所有 View 中共享的对象 `appModel`，其类型 `AppModel` 中储存需要在应用内共享的数据（如：用户的 token 是否过期）：

```swift
struct HollowApp: App {
    ...
    @StateObject var appModel = AppModel()
    ...
}
```

然后，通过 `.environmentObject()` 向环境注入此变量。我们便可以在 View 中通过 `@EnvironmentObject` 获取这个对象（的引用），并对其进行更改。

![](https://mermaid.ink/svg/eyJjb2RlIjoiZ3JhcGggQlRcbnYxW1ZpZXddXG52MltWaWV3XVxudjNbVmlld11cbmVvKFtFbnZpcm9ubWVudCBPYmplY3RdKVxuXG52MSAtLT4gZW9cbnYyIC0tPiBlb1xudjMgLS0-IGVvXG5cblxuc3ViZ3JhcGggQXBwXG5cdGVvXG5cdHYxXG5cdHYyXG5cdHYzXG5lbmRcblxuc3R5bGUgQXBwIGZpbGw6I2ZmZmZkZSxzdHJva2U6I2FhYWEzMzsiLCJtZXJtYWlkIjp7fSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)

在开发中，更多时候是由 View Model 来改变这个变量，而 View Model 本身是无法访问环境变量的。为了解决这一问题，我们定义一个 modifier，和一个与 `AppModel` 对应的结构 `AppModelState`。

```swift
struct AppModelBehaviour: ViewModifier {
    @EnvironmentObject var appModel: AppModel
    var state: AppModelState
    
    func body(content: Content) -> some View {
        content
            .onChange(of: state.shouldShowMainView) {
                withAnimation { appModel.isInMainView = $0 }
            }
        	...
    }
}
```

在 View Model 中，我们初始化一个 `AppModelState` 变量（`@Published`），当需要更改 `appModel` 中的变量时，我们改变这个 `AppModelState` 变量。在其对应的 View 中，我们应用上面的 modifier，监测 View Model 中 `AppModelState` 变量的改变，并将改变应用到共享的 `appModel` 中。这样，便实现了 View Model 对环境变量的间接修改。

![](https://mermaid.ink/svg/eyJjb2RlIjoiZ3JhcGggQlRcbnYxW1ZpZXddXG52bVtWaWV3IE1vZGVsXVxuZW8oW0Vudmlyb25tZW50IE9iamVjdF0pXG5cbnYxIC0tLT4gfFVwZGF0ZXwgZW9cbnYxIC0tPiB8T2JzZXJ2ZXwgdm1cblxuXG5zdWJncmFwaCBFbnZpcm9ubWVudFxuXHRlb1xuXHR2MVxuZW5kXG5cbnN0eWxlIEVudmlyb25tZW50IGZpbGw6I2ZmZmZkZSxzdHJva2U6I2FhYWEzMzsiLCJtZXJtYWlkIjp7fSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)

### 子 View 作为（暂时的）唯一数据源的实现

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
```

变量 `bindingPostWrapper` 为与上层 View 进行绑定的数据，而 `postDataWrapper` 为 `HollowDetailView` 获取并使用的数据。使用上层传入的数据对 `postDataWrapper` 进行初始化，子 View 使用 `postDataWrapper` 作为数据源；当 `postDataWrapper` 被更新时，更新 `bindingPostData`。这一步通过 `@Published` 变量作为 publisher 的 `projectedValue` 进行。
