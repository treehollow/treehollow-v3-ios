//
//  TextualLabel.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct TextualLabel: View {
    let primaryText: LocalizedStringKey
    let secondaryText: LocalizedStringKey
    
    init(primaryText: LocalizedStringKey, secondaryText: LocalizedStringKey) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
    }
    
    init(primaryText: String, secondaryText: LocalizedStringKey) {
        self.primaryText = LocalizedStringKey(primaryText)
        self.secondaryText = secondaryText
    }
    
    init(primaryText: LocalizedStringKey, secondaryText: String) {
        self.primaryText = primaryText
        self.secondaryText = LocalizedStringKey(secondaryText)
    }

    init(primaryText: String, secondaryText: String) {
        self.primaryText = LocalizedStringKey(primaryText)
        self.secondaryText = LocalizedStringKey(secondaryText)
    }
    
    var body: some View {
        HStack {
            Text(primaryText)
            Spacer()
            Text(secondaryText).foregroundColor(.secondary)
        }
    }
}
