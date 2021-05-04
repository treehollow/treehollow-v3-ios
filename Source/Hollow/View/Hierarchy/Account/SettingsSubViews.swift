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
    @Default(.usingSimpleAvatar) var usingSimpleAvatar
    
    @ScaledMetric(wrappedValue: 17) var colorHeight: CGFloat
    @ScaledMetric(wrappedValue: 30) var avatarHeight: CGFloat
    
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
                            CheckmarkButtonImage(isOn: customColorScheme == colorScheme)

                        }
                    }
                }
            }
            
            Section(
                header: Text("SETTINGSVIEW_APPEARENCE_THEMES_SECTION_HEADER").padding(.horizontal),
                footer: Text("SETTINGSVIEW_APPEARENCE_THEMES_SECTION_FOOTER").padding(.horizontal)
            ) {
                Button(action: {
                    tempColorSet = nil
                }) {
                    HStack {
                        Color.customColor(prefix: "button.gradient.1", colorSet: Defaults[.hollowType])
                            .colorScheme(.light)
                            .frame(maxHeight: colorHeight)
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(Circle())

                        Text("\(Defaults[.hollowType]?.name ?? "")")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("SETTINGSVIEW_APPEARENCE_THEMES_DEFAULT_CELL")
                            .foregroundColor(.secondary)
                        CheckmarkButtonImage(isOn: tempColorSet == nil)
                    }
                }
                ForEach(HollowType.allCases) { type in
                    if type != Defaults[.hollowType] {
                        Button(action: {
                            tempColorSet = type
                        }) {
                            HStack {
                                Color.customColor(prefix: "button.gradient.1", colorSet: type)
                                    .colorScheme(.light)
                                    .frame(maxHeight: colorHeight)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                
                                Text(type.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                CheckmarkButtonImage(isOn: tempColorSet == type)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("SETTINGSVIEW_APPEARANCE_AVATAR_HDR").padding(.horizontal)) {
                Button(action: { usingSimpleAvatar = false }) { HStack {
                    Avatar(foregroundColor: .hollowContentVoteGradient1, backgroundColor: .white, resolution: 4, padding: avatarHeight * 0.1, hashValue: 2021, name: "", options: .forceGraphical)
                        .frame(width: avatarHeight)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(.hollowContentVoteGradient1))
                        .padding(.trailing, 5)

                    Text("SETTINGSVIEW_APPEARANCE_GRAPHICAL_AVATAR_STYLE")
                        .foregroundColor(.primary)
                    Spacer()
                    CheckmarkButtonImage(isOn: !usingSimpleAvatar)
                }}
                
                Button(action: { usingSimpleAvatar = true }) { HStack {
                    Avatar(foregroundColor: .hollowContentVoteGradient1, backgroundColor: .white, resolution: 4, padding: avatarHeight * 0.1, hashValue: 0, name: "TH", options: .forceTextual)
                        .frame(width: avatarHeight)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(.hollowContentVoteGradient1))
                        .padding(.trailing, 5)

                    Text("SETTINGSVIEW_APPEARANCE_TEXTUAL_AVATAR_STYLE")
                        .foregroundColor(.primary)
                    Spacer()
                    CheckmarkButtonImage(isOn: usingSimpleAvatar)
                }}
            }
        }
        .defaultListStyle()
        .accentColor(.tint)
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
                        .defaultToggleStyle()
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
                            .onClickGesture { if let index = blockedTags.firstIndex(where: { $0 == tag }) {
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
                            .onClickGesture { withAnimation {
                                newTag = ""
                                showTextField = false
                            }}
                    }
                }
                
                Button(action: { withAnimation { showTextField = true } }) {
                    Text(Image(systemName: "plus")) + Text("  ") +
                        Text("SETTINGSVIEW_CONTENT_CUSTOM_FOLD_SECTION_ADD_MORE_BUTTON")
                        
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
        .accentColor(.tint)
        .navigationBarTitle(NSLocalizedString("SETTINGSVIEW_CONTENT_NAV_TITLE", comment: ""), displayMode: .inline)
    }
}

struct PushNotificationSettingsView: View {
    @State private var granted: Bool = false
    @State private var isEditing = false
    @State private var isCheckingAuthorization = true
    @ObservedObject var viewModel: ViewModel
    
    @Default(.showUpdateAlert) var showUpdateAlert
    
    var body: some View {
        List {
            if !granted && !isCheckingAuthorization {
                ImageTitledStack(spacing: 5, systemImageName: "bell.slash") {
                    Text("SETTINGSVIEW_NOTIFICATION_NO_ACCESS_LABEL")
                        .font(.headline)
                        .padding(.bottom, 3)
                    Text("SETTINGSVIEW_NOTIFICATION_NO_ACCESS_DESCRIPTION")
                    Link("SETTINGSVIEW_NOTIFICATION_GO_TO_SETTINGS", destination: URL(string: UIApplication.openSettingsURLString)!)
                        .padding(.top, 10)
                }
                .padding(.vertical)
            } else {
                Section {
                    ForEach(PushNotificationType.Enumeration.allCases) { type in
                        // Read only mode
                        Button(
                            action: {
                                viewModel.tempNotificationType[keyPath: type.keyPath].toggle()
                            }) {
                            HStack {
                                Text(type.description)
                                Spacer()
                                if isEditing || viewModel.isLoading {
                                    let selected = viewModel.tempNotificationType[keyPath: type.keyPath]
                                    CheckmarkButtonImage(isOn: selected)
                                } else {
                                    if viewModel.notificationType[keyPath: type.keyPath] {
                                        Image(systemName: "checkmark")
                                            .imageScale(.medium)
                                    }
                                }
                            }
                        }
                        .foregroundColor(.primary)
                        .disabled(!isEditing || viewModel.isLoading)
                        
                    }
                }
                
                Section {
                    HStack {
                        Text("SETTINGSVIEW_NOTIFICATION_UPDATE_NOTIFICATION")
                        Spacer()
                        Toggle("", isOn: $showUpdateAlert)
                            .defaultToggleStyle()
                    }
                }
            }
        }
        .accentColor(.tint)
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
        .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
        .onAppear { checkForPermissions() }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
            perform: { _ in checkForPermissions() }
        )
    }
    
    func checkForPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: Constants.Application.requestedNotificationOptions,
            completionHandler: { granted, _ in
                DispatchQueue.main.async {
                    if granted && !self.granted { self.viewModel.getPushTypes() }
                    self.granted = granted
                    self.isCheckingAuthorization = false
                }
            })
    }
    
    class ViewModel: ObservableObject, AppModelEnvironment {
        @Published var isLoading = false
        @Published var notificationType = Defaults[.notificationTypeCache]
        @Published var tempNotificationType = Defaults[.notificationTypeCache]
        @Published var errorMessage: (title: String, message: String)?
        @Published var appModelState = AppModelState()
        
        var cancellables = Set<AnyCancellable>()
        
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
            
            #if !targetEnvironment(macCatalyst)
            OpenURLSettingsView()
            #endif
            
            Section {
                NavigationLink("SETTINGSVIEW_OTHER_EXP_FEAT_NAV_TITLE", destination: ExperimentalFeaturesView())
            }
        }
        .defaultListStyle()
        .navigationBarTitle(NSLocalizedString("SETTINGSVIEW_OTHER_NAV_TITLE", comment: ""))
    }
    
    private struct OpenURLSettingsView: View {
        @Default(.openURLMethod) var openMethod
        
        var body: some View {
            Section(
                header: Text("SETTINGSVIEW_OTHER_OPEN_URL_SECTION_TITLE").padding(.horizontal)
            ) {
                ForEach(OpenURLHelper.OpenMethod.allCases) { method in
                    Button(action: {
                        withAnimation {
                            openMethod = method
                        }
                    }) {
                        HStack {
                            Text(method.description)
                            Spacer()
                            CheckmarkButtonImage(isOn: openMethod == method)
                        }
                    }
                    .accentColor(.primary)
                }
            }
            .accentColor(.tint)
        }
    }
    
    private struct CacheManagementView: View {
        @ObservedObject private var viewModel = ViewModel()
        
        var body: some View {
            Section(
                header: Text("SETTINGSVIEW_OTHER_CACHE_SECTION_HEADER").padding(.horizontal).padding(.top)) {
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
            .accentColor(.tint)
        }
        
        private class ViewModel: ObservableObject {
            @Published var cacheSize: String?
            @Published var isClearing = false
            
            init() {
                getSize()
            }
            
            func getSize() {
                cacheSize = nil
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
                    PostCache.shared.clear()
                    KingfisherManager.shared.cache.clearCache(completion: {
                        DispatchQueue.main.async { withAnimation {
                            self.isClearing = false
                            self.getSize()
                        }}
                    })
                }
            }
        }
    }
    
    private struct ExperimentalFeaturesView: View {
        @Default(.reduceImageQuality) var reduceImageQuality

        var body: some View {
            List {
                ImageTitledStack(systemImageName: "curlybraces") {
                    Text("SETTINGSVIEW_OTHER_EXP_FEAT_DESCRIPTION")
                }
                .padding(.vertical)
                
                Section(
                    header: Text("SETTINGSVIEW_OTHER_EXP_REDUCE_IMG_QUALITY_HEADER").padding(.horizontal),
                    footer: Text("SETTINGSVIEW_OTHER_EXP_REDUCE_IMG_QUALITY_FOOTER").padding(.horizontal)) {
                    HStack {
                        Text("SETTINGSVIEW_OTHER_EXP_REDUCE_IMG_QUALITY_LABEL")
                        Spacer()
                        
                        Toggle("", isOn: $reduceImageQuality)
                            .defaultToggleStyle()
                    }
                }
                
            }
            .defaultListStyle()
            .navigationTitle(NSLocalizedString("SETTINGSVIEW_OTHER_EXP_FEAT_NAV_TITLE", comment: ""))
        }
    }
}
