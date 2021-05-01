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
    let options: Options
    
    init(primaryText: LocalizedStringKey, secondaryText: LocalizedStringKey, options: Options = []) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.options = options
    }
    
    init(primaryText: String, secondaryText: LocalizedStringKey, options: Options = []) {
        self.primaryText = LocalizedStringKey(primaryText)
        self.secondaryText = secondaryText
        self.options = options
    }
    
    init(primaryText: LocalizedStringKey, secondaryText: String, options: Options = []) {
        self.primaryText = primaryText
        self.secondaryText = LocalizedStringKey(secondaryText)
        self.options = options
    }

    init(primaryText: String, secondaryText: String, options: Options = []) {
        self.primaryText = LocalizedStringKey(primaryText)
        self.secondaryText = LocalizedStringKey(secondaryText)
        self.options = options
    }
    
    var body: some View {
        HStack {
            Text(primaryText)
            Spacer()
            Text(secondaryText)
                .foregroundColor(.secondary)
                .font(.system(.body, design: options.contains(.monospaced) ? .monospaced : .default))
        }
    }
}

extension TextualLabel {
    struct Options: OptionSet {
        let rawValue: Int
        static let monospaced = Options(rawValue: 1 << 1)
    }
}
