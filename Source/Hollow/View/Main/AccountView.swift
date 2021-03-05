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
                            Label(NSLocalizedString("ACCOUNTVIEW_ACCOUNT_CELL", comment: ""), systemImage: "person")
                        })
                    NavigationLink(
                        destination: /*@START_MENU_TOKEN@*/Text("Destination")/*@END_MENU_TOKEN@*/,
                        label: {
                            Label(NSLocalizedString("ACCOUNTVIEW_SETTINGS_CELL", comment: ""), systemImage: "gear")
                        })
                }
                Section(header: Text("ACCOUNTVIEW_INFO_HEADER")) {
                    NavigationLink(
                        destination: Text("Regulation"),
                        label: {
                            Label(NSLocalizedString("ACCOUNTVIEW_RULES_CELL", comment: ""), systemImage: "doc.plaintext")
                        })
                    NavigationLink(
                        destination: Text("Regulation"),
                        label: {
                            Label(NSLocalizedString("ACCOUNTVIEW_PRIVACY_CELL", comment: ""), systemImage: "checkmark.shield")
                        })
                    NavigationLink(
                        destination: Text("About"),
                        label: {
                            Label(NSLocalizedString("ACCOUNTVIEW_ABOUT_CELL", comment: ""), systemImage: "info.circle")
                        })

                }
                
                Section {
                    Button(action: {}) {
                        Label(NSLocalizedString("ACCOUNTVIEW_CONTACT_US_CELL", comment: ""), systemImage: "envelope")
                    }

                    // TODO: shows only when available
                    Button(action: {}) {
                        Label(NSLocalizedString("ACCOUNTVIEW_UPDATE_CELL", comment: ""), systemImage: "arrow.up")
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
            .navigationTitle(NSLocalizedString("ACCOUNTVIEW_NAV_TITLE", comment: ""))
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
