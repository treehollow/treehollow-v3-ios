//
//  AboutView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults

struct AboutView: View {
    @Environment(\.openURL) var openURL
    @Default(.versionUpdateInfoCache) var versionUpdateInfoCache

    var body: some View {
        List {
            Section {
                HStack(spacing: 20) {
                    if let icon = Bundle.main.icon {
                        Image(uiImage: icon)
                            .roundedCorner(14.5)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(Constants.Application.appLocalizedName)
                            .font(.headline)
                            .fontWeight(.heavy)
                        Text("ABOUTVIEW_COPYRIGHT_NOTICE")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 10)
                
                HStack {
                    Text("ABOUTVIEW_VERSION")
                    Spacer()
                    Text(Constants.Application.appVersion)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("ABOUTVIEW_BUILD_VERSION")
                    Spacer()
                    Text(Constants.Application.buildVersion)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                if let cache = versionUpdateInfoCache, UIDevice.isPad {
                    NavigationLink(
                        destination: VersionUpdateView(info: cache, showItem: false),
                        label: {
                            Text("VERSION_UPDATE_VIEW_NAV_TITLE")
                        })
                }

            }
            
            Section {
                ImageTitledStack(systemImageName: "point.topleft.down.curvedto.point.bottomright.up") {
                    Text("ABOUTVIEW_OPENSOURCE_NOTICE")
                        .accentColor(.hollowContentVoteGradient1)
                        .frame(maxHeight: .infinity)
                }
                .padding(.vertical)

                NavigationLink(
                    NSLocalizedString("ABOUTVIEW_LICENSE_NAV_TITLE", comment: ""),
                    destination: DependenciesView()
                )
            }
            
            if UIDevice.isPad {
                NavigationLink(
                    destination: ProviderInfoView(),
                    label: {
                        HStack {
                            Text("SETTINGSVIEW_PROVIDER_SECTION_TITLE")
                            Spacer()
                            Text(Defaults[.hollowConfig]?.name ?? "")
                                .foregroundColor(.secondary)
                        }
                    })
            }
            
            Section {
                NavigationLink(
                    "ABOUTVIEW_CONTRIBUTORS_FOOTER_TITLE",
                    destination: List {
                        let contributors = ["@Cris", "@Elio", "@liang2kl", "@pkuhollow"]
                        ImageTitledStack(spacing: 5, systemImageName: "person.3") {
                            Text("ABOUTVIEW_CONTRIBUTORS_FOOTER_TITLE")
                                .fontWeight(.bold)
                                .foregroundColor(.tint)
                                .padding(.bottom, 5)
                            ForEach(contributors, id: \.self) { name in
                                Text(verbatim: name)
                                    .dynamicFont(size: 16, design: .monospaced)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .defaultListStyle()
                    .navigationTitle("ABOUTVIEW_CONTRIBUTORS_FOOTER_TITLE")
                )
            }
            
        }
        .navigationTitle("ACCOUNTVIEW_ABOUT_CELL")
        .defaultListStyle()
    }
}

extension AboutView {
    struct DependenciesView: View {
        @Environment(\.openURL) var openURL
        
        var body: some View {
            List {
                ForEach(Dependency.all) { dependency in
                    NavigationLink(
                        dependency.module,
                        destination:
                            ScrollView {
                                Text(dependency.license)
                                    .dynamicFont(size: 14, design: .monospaced)
                                    .padding()
                                    .horizontalCenter()
                                    .lineSpacing(3)
                            }
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.uiColor(.secondarySystemBackground).ignoresSafeArea())
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        openURL(URL(string: dependency.url)!)
                                    }) {
                                        Image(systemName: "arrow.turn.up.right")
                                    }
                            )
                            .navigationBarTitle(dependency.module)
                    )
                }
            }
            .defaultListStyle()
            .navigationBarTitle(NSLocalizedString("ABOUTVIEW_LICENSE_NAV_TITLE", comment: ""))
        }
    }
}

fileprivate struct Dependency: Codable, Identifiable {
    var id: String { module }
    var module: String
    var url: String
    var license: String
    
    static var all: [Dependency] {
        let path = Bundle.main.path(forResource: "dependencies", ofType: "json")!
        let data = FileManager.default.contents(atPath: path)!
        let decoder = JSONDecoder()
        return try! decoder.decode([Dependency].self, from: data)
    }
}

fileprivate extension Bundle {
    var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let icon = files.last {
            return UIImage(named: icon)
        }
        return nil
    }
}
