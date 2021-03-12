//
//  AboutView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) var openURL

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

            }
            
            NavigationLink(
                destination: Text(""),
                label: {
                    Text("ACCOUNTVIEW_PRIVACY_CELL")
                })
            
            Section(
                footer:
                    Text("ABOUTVIEW_OPENSOURCE_NOTICE")
                    .padding(.horizontal)
            ) {
                Button(action: {
                    openURL(URL(string: "https://github.com/treehollow/treehollow-v3-ios")!)
                }) {
                    Image("github-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 15)
                        .foregroundColor(.primary)
                }
                Button("ABOUTVIEW_OPENSOURCE_NOTICE_LICENSE", action: {
                    openURL(URL(string: "https://www.gnu.org/licenses/agpl-3.0.html")!)
                })
                .accentColor(.primary)
            }
            
            Section(
                footer:
                    VStack(alignment: .leading, spacing: 5) {
                        Text(NSLocalizedString("ABOUTVIEW_CONTRIBUTORS_FOOTER_TITLE", comment: ""))
                            .bold()
                        Text("@Cris\n@Elio\n@liang2kl\n@pkuhollow")
                            .font(.system(.footnote, design: .monospaced))
                            .lineSpacing(2)
                    }
                    .padding([.horizontal, .top])
            ) {

                NavigationLink(
                    NSLocalizedString("ABOUTVIEW_LICENSE_NAV_TITLE", comment: ""),
                    destination: DependenciesView()
                )
            }
            
        }
        .defaultListStyle()
        .navigationBarTitle(NSLocalizedString("ACCOUNTVIEW_ABOUT_CELL", comment: ""))
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


#if DEBUG
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
#endif
