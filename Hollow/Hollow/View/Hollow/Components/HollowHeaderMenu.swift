//
//  HollowHeaderMenu.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowHeaderMenu: View {
    var body: some View {
        Section {
            Button(action: {
                
            }) {
                Label("Report", systemImage: "exclamationmark")
            }
        }
        Section {
            Button(action: {
                
            }) {
                Label(LocalizedStringKey("Block This Post"), systemImage: "xmark")
            }
            Button(action: {
                
            }) {
                Label(LocalizedStringKey("Block Relative Tags"), systemImage: "xmark")
            }
        }
    }
}

#if DEBUG
struct HollowHeaderMenu_Previews: PreviewProvider {
    static var previews: some View {
        HollowHeaderMenu()
    }
}
#endif
