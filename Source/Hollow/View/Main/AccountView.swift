//
//  AccountView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct AccountView: View {
    @Binding var presented: Bool
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("ACCOUNTVIEW_ACCOUNT_HEADER")) {
                    NavigationLink(
                        destination: AccountInfoView(),
                        label: {
                            Label("ACCOUNTVIEW_ACCOUNT_CELL", systemImage: "person")
                        })
                    NavigationLink(
                        destination: /*@START_MENU_TOKEN@*/Text("Destination")/*@END_MENU_TOKEN@*/,
                        label: {
                            Label("ACCOUNTVIEW_SETTINGS_CELL", systemImage: "gear")
                        })
                }
                Section(header: Text("ACCOUNTVIEW_INFO_HEADER")) {
                    NavigationLink(
                        destination: Text("Regulation"),
                        label: {
                            Label(LocalizedStringKey("ACCOUNTVIEW_RULES_CELL"), systemImage: "doc.plaintext")
                        })
                    NavigationLink(
                        destination: Text("Regulation"),
                        label: {
                            Label(LocalizedStringKey("ACCOUNTVIEW_PRIVACY_CELL"), systemImage: "checkmark.shield")
                        })
                    NavigationLink(
                        destination: Text("About"),
                        label: {
                            Label(LocalizedStringKey("ACCOUNTVIEW_ABOUT_CELL"), systemImage: "info.circle")
                        })

                }
                
                Section {
                    Button(action: {}) {
                        Label("ACCOUNTVIEW_CONTACT_US_CELL", systemImage: "envelope")
                    }

                    // TODO: shows only when available
                    Button(action: {}) {
                        Label("ACCOUNTVIEW_UPDATE_CELL", systemImage: "arrow.up")
                    }

                }
                
                Section {
                    Button(action: {}) {
                        Text("ACCOUNTVIEW_LOGOUT_BUTTON")
                            .foregroundColor(.red)
                            .horizontalCenter()
                    }
                }

            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("ACCOUNTVIEW_NAV_TITLE")
            .navigationBarItems(leading: Button(action: { presented = false }) {
                Image(systemName: "xmark")
                    .foregroundColor(.hollowContentText)
            })
        }
        .accentColor(.hollowContentText)
    }
}

#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(presented: .constant(true))
    }
}
#endif
