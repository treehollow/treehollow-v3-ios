# treehollow-v3-ios

[![Build status](https://build.appcenter.ms/v0.1/apps/ecb32276-29a0-4925-a8aa-f46d00effd10/branches/main/badge)](https://appcenter.ms)

树洞 iOS / macOS 客户端，使用 SwiftUI 开发，支持 [T大树洞](https://thuhole.com)、[未名树洞](https://www.pkuhollow.com)。

与树洞 HTTP API 相关的实现使用独立的依赖库 [HollowCore](https://github.com/liang2kl/HollowCore)。

## 下载

<a href='https://apps.apple.com/cn/app/treehollow/id1556835658'>
    <img align="center" height=40px src='Documentation/Assets/app_store_ios.svg' style="padding-right: 10px"/>
</a>
<a href='https://apps.apple.com/cn/app/treehollow/id1556835658'>
    <img align="center" height=40px src='Documentation/Assets/app_store_mac.svg'/>
</a>

## Build

### 环境要求

树洞客户端使用 iOS 15 SDK，需要 `macOS 11.3+`、`Xcode 13+`。

> 因 SwiftUI API 变动较大，`v3.2.1` 之后的新版本不再支持 iOS 14。若需编译适配 iOS 14 的版本，请从 `3c11bd7` 创建分支。

### 编译安装

1. 用 Xcode 打开 `Hollow.xcodeproj` 文件
2. 等待 Swift Package Manager 加载依赖库
3. 点击项目，在 TARGETS - Hollow - Signing & Capabilities 的 `Team` 中选择你的开发者账号
4. 编译、运行

加载依赖库可能会由于网络环境的问题出现失败的情况，可以参考 [这篇文章](https://gist.github.com/liang2kl/15237e23b06e737f036b8c1c3e5c0102)。

## 文档

有关应用架构的说明，参见 [architecture.md](Documentation/architecture.md)。

当前项目源文件目录结构如下：

- [Hollow](Source/Hollow)：iOS Target（包括 Catalyst 版 macOS app）
- [HollowWidget](Source/HollowWidget)：iOS 主屏幕小组件，编译 flag 为 `WIDGET`

原有的 macOS Target 已被删除。

## 贡献

可以通过 Pull Request 和 Issues 参与到树洞 iOS 客户端的开发中。

在添加新功能或修改 bug 之外，十分欢迎对已有代码进行优化，包括但不限于：修改不符合规范的命名、简化啰嗦的代码、优化不好的算法、添加注释、删除无用代码等。

涉及到代码修改的贡献应注意：

- 遵循 Swift 的 [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- 在关键代码处添加必要的英文注释

## 开源许可

以 [AGPL-3.0 协议](LICENSE) 开源，但**不包含**：

- [Source/Hollow/Assets.xcassets/AppIcon.appiconset](Source/Hollow/Assets.xcassets/AppIcon.appiconset) 目录下所有内容
