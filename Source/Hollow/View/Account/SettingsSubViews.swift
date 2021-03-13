//
//  SettingsSubViews.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults
import Kingfisher
import Cache
import Combine

struct AppearanceSettingsView: View {
    @Default(.colorScheme) var customColorScheme
    @Default(.customColorSet) var customColorSet
    @Default(.tempCustomColorSet) var tempColorSet
    
    @ScaledMetric(wrappedValue: 17) var colorHeight: CGFloat
    
    var body: some View {
        List {
            Section(
                header: Text("SETTINGSVIEW_APPEARENCE_COLOR_SCHEME")
                    .padding(.top)
                    .padding(.horizontal)
            ) {
                ForEach(CustomColorScheme.allCases) { colorScheme in
                    Button(action: {
                        customColorScheme = colorScheme
                        withAnimation {
                            IntegrationUtilities.setCustomColorScheme()
                        }
                    }) {
                        HStack {
                            Text(colorScheme.description)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(
                                systemName: customColorScheme == colorScheme ?
                                    "checkmark.circle.fill" : "circle"
                            )
                            .foregroundColor(
                                customColorScheme == colorScheme ?
                                    .tint : .uiColor(.systemFill)
                            )
                        }
                    }
                }
            }
            
            Section(
                header: Text("SETTINGSVIEW_APPEARENCE_THEMES_SECTION_HEADER").padding(.horizontal),
                footer: Text("SETTINGSVIEW_APPEARENCE_THEMES_SECTION_FOOTER").padding(.horizontal)
            ) {
                Button(action: {
                    customColorSet = nil
                    tempColorSet = nil
                }) {
                    HStack {
                        (Text("SETTINGSVIEW_APPEARENCE_THEMES_DEFAULT_CELL") + Text(" - \(Defaults[.hollowType]?.name ?? "")"))
                            .foregroundColor(.primary)
                        Spacer()
                        Color.customColor(prefix: "button.gradient.1", colorSet: Defaults[.hollowType])
                            .frame(maxHeight: colorHeight)
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(lineWidth: 2).foregroundColor(.uiColor(.systemFill)))
                        Image(
                            systemName: customColorSet == nil && tempColorSet == nil ?
                                "checkmark.circle.fill" : "circle"
                        )
                    }
                }
                ForEach(HollowType.allCases) { type in
                    if type != Defaults[.hollowType] {
                        Button(action: {
                            customColorSet = nil
                            tempColorSet = type
                        }) {
                            HStack {
                                Text(type.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                Color.customColor(prefix: "button.gradient.1", colorSet: type)
                                    .frame(maxHeight: colorHeight)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(lineWidth: 2).foregroundColor(.uiColor(.systemFill)))
                                Image(
                                    systemName: tempColorSet == type || customColorSet == type ?
                                        "checkmark.circle.fill" : "circle"
                                )
                            }
                        }
                    }
                }
            }
        }
        .defaultListStyle()
        .navigationBarTitle(NSLocalizedString("SETTINGSVIEW_APPEARANCE_NAV_TITLE", comment: ""), displayMode: .inline)
    }
}

struct ContentSettingsView: View {
    @Default(.foldPredefinedTags) var fold
    @Default(.blockedTags) var blockedTags
    @State private var showTextField = false
    @State private var newTag = ""
    @State private var showAlert = false
    var body: some View {
        List {
            Section {
                HStack {
                    Text("SETTINGSVIEW_CONTENT_FOLD_CELL")
                    Spacer()
                    Toggle(isOn: $fold, label: {})
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .tint))
                }
                let tags = Defaults[.hollowConfig]?.foldTags ?? []
                if !tags.isEmpty {
                    Text(tags.joined(separator: ", "))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            Section(
                header:
                    Text("SETTINGSVIEW_CONTENT_CUSTOM_FOLD_SECTION_HEADER")
                    .padding(.horizontal),
                footer:
                    Text("SETTINGSVIEW_CONTENT_FOLD_SECTION_FOOTER")
                    .padding(.horizontal)
            ) {
                ForEach(blockedTags, id: \.self) { tag in
                    HStack {
                        Text(tag)
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.tint)
                            .imageScale(.medium)
                            .onTapGesture { if let index = blockedTags.firstIndex(where: { $0 == tag }) {
                                _ = withAnimation { blockedTags.remove(at: index) }
                            }}
                    }
                }
                
                if showTextField {
                    HStack {
                        TextField(
                            NSLocalizedString("SETTINGSVIEW_CONTENT_CUSTOM_FOLD_TEXTFIELD_PLACEHOLDER", comment: ""),
                            text: $newTag,
                            onCommit: {
                                if newTag == "" {
                                    showAlert = true
                                    return
                                }
                                for tag in blockedTags {
                                    if tag == newTag {
                                        showAlert = true
                                        return
                                    }
                                }
                                blockedTags.append(newTag)
                                newTag = ""
                                showTextField = false
                            })
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.uiColor(.systemFill))
                            .imageScale(.medium)
                            .onTapGesture { withAnimation {
                                newTag = ""
                                showTextField = false
                            }}
                    }
                }
                
                Button(action: { withAnimation { showTextField = true } }) {
                    Label(NSLocalizedString("SETTINGSVIEW_CONTENT_CUSTOM_FOLD_SECTION_ADD_MORE_BUTTON", comment: ""), systemImage: "plus")
                }
                .disabled(showTextField)
                
            }
        }
        .styledAlert(
            presented: $showAlert,
            title: NSLocalizedString("SETTINGSVIEW_CONTENT_CUSTOM_FOLD_INVALID_ALERT_TITLE", comment: ""),
            message: nil,
            buttons: [.ok]
        )
        .defaultListStyle()
        .navigationBarTitle(NSLocalizedString("SETTINGSVIEW_CONTENT_NAV_TITLE", comment: ""), displayMode: .inline)
    }
}

struct PushNotificationSettingsView: View {
    @State private var granted: Bool = false
    @State private var isEditing = false
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        List {
            if !granted {
                Text("SETTINGSVIEW_NOTIFICATION_NO_ACCESS_LABEL")
                Text("SETTINGSVIEW_NOTIFICATION_NO_ACCESS_DESCRIPTION")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                ForEach(PushNotificationType.Enumeration.allCases) { type in
                    // Read only mode
                    Button(
                        action: {
                            viewModel.tempNotificationType[keyPath: type.keyPath].toggle()
                        }) {
                        HStack {
                            Text(type.description)
                            Spacer()
                            if isEditing {
                                let selected = viewModel.tempNotificationType[keyPath: type.keyPath]
                                Image(
                                    systemName: selected ? "checkmark.circle.fill" : "circle"
                                )
                                .foregroundColor(
                                    selected ? .tint : .uiColor(.systemFill)
                                )
                            } else {
                                if viewModel.notificationType[keyPath: type.keyPath] {
                                    Image(systemName: "checkmark")
                                        .imageScale(.medium)
                                }
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    .disabled(!isEditing)
                    
                }
            }
        }
        .defaultListStyle()
        .navigationBarTitle(NSLocalizedString("SETTINGSVIEW_NOTIFICATION_NAV_TITLE", comment: ""))
        .navigationBarItems(
            leading: Group { if granted && isEditing {
                Button("SETTINGSVIEW_NOTIFICATION_EDIT_CANCEL") {
                    withAnimation { self.isEditing = false }
                }
            }}
        )
        .navigationBarItems(
            leading: Group { if granted && isEditing {
                Button("SETTINGSVIEW_NOTIFICATION_EDIT_CANCEL") {
                    withAnimation { self.isEditing = false }
                }
            }},
            trailing: Group { if granted {
                Button(
                    self.isEditing ?
                        NSLocalizedString("SETTINGSVIEW_NOTIFICATION_SET_BUTTON", comment: "") :
                        NSLocalizedString("SETTINGSVIEW_NOTIFICATION_EDIT_BUTTON", comment: "")
                ) {
                    if isEditing {
                        // Set
                        withAnimation {
                            self.isEditing = false
                        }
                        viewModel.setPushTypes()
                    } else {
                        // Start
                        withAnimation {
                            self.isEditing = true
                            viewModel.tempNotificationType = viewModel.notificationType
                        }
                    }
                }
            }}
        )
        .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
        .modifier(AppModelBehaviour(state: viewModel.appModelState))
        .modifier(LoadingIndicator(isLoading: viewModel.isLoading, disableWhenLoading: true))
        .onAppear { checkForPermissions() }
    }
    
    func checkForPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: Constants.Application.requestedNotificationOptions,
            completionHandler: { granted, _ in
            self.granted = granted
        })
    }
    
    private class ViewModel: ObservableObject, AppModelEnvironment {
        @Published var isLoading = false
        @Published var notificationType = Defaults[.notificationTypeCache]
        @Published var tempNotificationType = Defaults[.notificationTypeCache]
        @Published var errorMessage: (title: String, message: String)?
        @Published var appModelState = AppModelState()
        
        var cancellables = Set<AnyCancellable>()
        
        init() {
            getPushTypes()
        }
        
        func getPushTypes() {
            guard let config = Defaults[.hollowConfig],
                  let token = Defaults[.accessToken] else { return }
            let request = GetPushRequest(configuration: .init(apiRoot: config.apiRootUrls, token: token))
            withAnimation { self.isLoading = true }
            request.publisher
                .sinkOnMainThread(receiveError: { error in
                    withAnimation { self.isLoading = false }
                    self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
                }, receiveValue: { result in
                    withAnimation { self.isLoading = false }
                    self.notificationType = result
                    self.tempNotificationType = result
                    Defaults[.notificationTypeCache] = result
                })
                .store(in: &cancellables)
        }
        
        func setPushTypes() {
            guard tempNotificationType != Defaults[.notificationTypeCache] else { return }
            guard let config = Defaults[.hollowConfig],
                  let token = Defaults[.accessToken] else { return }
            let request = SetPushRequest(configuration: .init(type: tempNotificationType, apiRoot: config.apiRootUrls, token: token))
            withAnimation { self.isLoading = true }
            
            request.publisher
                .sinkOnMainThread(receiveError: { error in
                    withAnimation { self.isLoading = false }
                    self.tempNotificationType = self.notificationType
                    self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
                }, receiveValue: { _ in
                    Defaults[.notificationTypeCache] = self.tempNotificationType
                    self.notificationType = self.tempNotificationType
                    withAnimation { self.isLoading = false }
                    self.sendDeviceToken()
                })
                .store(in: &cancellables)
        }
        
        func sendDeviceToken() {
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
            delegate.setupRemoteNotifications(UIApplication.shared)
        }
    }
}

struct OtherSettingsView: View {
    @State private var isLoading = false
    @State private var cacheSize: String?
    
    var body: some View {
        List {
            CacheManagementView()
        }
        .defaultListStyle()
        .navigationBarTitle(NSLocalizedString("SETTINGSVIEW_OTHER_NAV_TITLE", comment: ""))
    }
    
    private struct CacheManagementView: View {
        @ObservedObject private var viewModel = ViewModel()
        
        var body: some View {
            Section(
                header: Text("SETTINGSVIEW_OTHER_CACHE_SECTION_HEADER").padding(.horizontal)) {
                Button(action: viewModel.clearCache) {
                    HStack {
                        Text(
                            !viewModel.isClearing ?
                                NSLocalizedString("SETTINGSVIEW_OTHER_CLEAR_CACHE_BUTTON", comment: "") :
                                NSLocalizedString("SETTINGSVIEW_OTHER_CLEARING_LABEL", comment: "")
                        )
                        Spacer()
                        Text(viewModel.cacheSize ?? (NSLocalizedString("SETTINGSVIEW_OTHER_CACHE_CALCULATING_LABEL", comment: "") + "..."))
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(viewModel.isClearing)
            }
        }
        
        private class ViewModel: ObservableObject {
            @Published var cacheSize: String?
            @Published var isClearing = false
            
            init() {
                getSize()
            }
            
            func getSize() {
                DispatchQueue.global(qos: .background).async {
                    KingfisherManager.shared.cache.calculateDiskStorageSize(completion: { result in
                        if let count = try? result.get() {
                            let formatter = ByteCountFormatter()
                            formatter.allowedUnits = [.useMB]
                            formatter.countStyle = .file
                            DispatchQueue.main.async {
                                self.cacheSize = formatter.string(fromByteCount: Int64(count))
                            }
                        }
                    })
                }
            }
            
            func clearCache() {
                withAnimation {
                    isClearing = true
                }
                DispatchQueue.global(qos: .background).async {
                    PostCache().clear()
                    KingfisherManager.shared.cache.clearCache()
                    DispatchQueue.main.async { withAnimation {
                        self.isClearing = false
                        self.getSize()
                    }}
                }
            }
        }
    }
}
