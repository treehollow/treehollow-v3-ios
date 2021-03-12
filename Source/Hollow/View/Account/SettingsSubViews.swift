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

struct AppearanceSettingsView: View {
    @Default(.colorScheme) var customColorScheme
    
    var body: some View {
        List {
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
                                .hollowContentText :  .uiColor(.systemFill)
                        )
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
                        .toggleStyle(SwitchToggleStyle(tint: .hollowContentText))
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
                            .foregroundColor(.hollowContentText)
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
    
    var body: some View {
        
        Text("")
            .onAppear { checkForPermissions() }
    }
    
    func checkForPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: Constants.Application.requestedNotificationOptions,
            completionHandler: { granted, _ in
            self.granted = granted
        })
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
                        Text(viewModel.cacheSize ?? ("SETTINGSVIEW_OTHER_CACHE_CALCULATING_LABEL" + "..."))
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
                    try? PostCache().postStorage?.removeAll()
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
