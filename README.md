# treehollow-v3-ios

[![Build status](https://build.appcenter.ms/v0.1/apps/ecb32276-29a0-4925-a8aa-f46d00effd10/branches/main/badge)](https://appcenter.ms)

树洞 iOS / macOS 客户端，使用 SwiftUI 开发，支持 [T大树洞](https://thuhole.com)、[未名树洞](https://www.pkuhollow.com)。

## 下载

<a href='https://apps.apple.com/cn/app/treehollow/id1556835658#?platform=iphone'>
    <img align="center" height=40px src='Documentation/Assets/app_store_ios.svg' style="padding-right: 10px"/>
</a>
<a href='https://apps.apple.com/cn/app/treehollow/id1556835658#?platform=mac'>
    <img align="center" height=40px src='Documentation/Assets/app_store_mac.svg'/>
</a>

## Build

### 环境要求

树洞客户端使用 iOS 14 SDK，需要 `macOS 11.0+`、`Xcode 12+`。

### 克隆

```
git clone https://github.com/treehollow/treehollow-v3-ios.git
```

### 编译安装

1. 用 Xcode 打开 `Hollow.xcodeproj` 文件。
2. 等待 Swift Package Manager 加载依赖库。
3. 点击项目，在 `TARGETS-Hollow-Signing & Capabilities` 的 `Team` 中选择你的开发者账号。
4. 编译、运行。

## 开源许可

以 [AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0.html) 协议开源，但**不包含**：

- [Source/Hollow/Assets.xcassets/AppIcon.appiconset](Source/Hollow/Assets.xcassets/AppIcon.appiconset) 目录下所有内容