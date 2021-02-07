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
                Section(header: Text("account")) {
                    NavigationLink(
                        destination: Text("Account"),
                        label: {
                            Label(LocalizedStringKey("Account"), systemImage: "person")
                        })
                    NavigationLink(
                        destination: /*@START_MENU_TOKEN@*/Text("Destination")/*@END_MENU_TOKEN@*/,
                        label: {
                            Label("Settings", systemImage: "gear")
                        })
                }
                Section(header: Text("info")) {
                    NavigationLink(
                        destination: Text("Regulation"),
                        label: {
                            Label(LocalizedStringKey("Rules"), systemImage: "doc.plaintext")
                        })
                    NavigationLink(
                        destination: Text("Regulation"),
                        label: {
                            Label(LocalizedStringKey("Privacy"), systemImage: "checkmark.shield")
                        })
                    NavigationLink(
                        destination: Text("About"),
                        label: {
                            Label(LocalizedStringKey("About"), systemImage: "info.circle")
                        })

                }
                
                Section {
                    Button(action: {}) {
                        Label("Contact Us", systemImage: "envelope")
                    }

                    // TODO: shows only when available
                    Button(action: {}) {
                        Label("Update", systemImage: "arrow.up")
                    }

                }
                
                Section {
                    Button(action: {}) {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .horizontalCenter()
                    }
                }

            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(LocalizedStringKey("Account"))
            .navigationBarItems(leading: Button(action: { presented = false }) {
                Image(systemName: "xmark")
                    .foregroundColor(.hollowContentText)
            })
            .accentColor(.hollowContentText)
        }
    }
}

#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(presented: .constant(true))
    }
}
#endif
