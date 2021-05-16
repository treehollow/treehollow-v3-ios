//
//  CustomColors.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

typealias ColorSet = HollowType

/// Color extension for customized colors, adapting different themes.
extension Color {
    
    static func customColor(prefix: String, colorSet: ColorSet? = nil) -> Color {
        // Prefers custom set
        let finalColorSet = colorSet ?? Defaults[.customColorSet] ?? Defaults[.hollowType] ?? .thu
        return Color(prefix + "." + finalColorSet.description)
    }
    
    static var hollowContentVoteGradient1: Color { customColor(prefix: "hollow.content.vote.gradient.1") }
    
    static var hollowContentVoteGradient2: Color { customColor(prefix: "hollow.content.vote.gradient.2") }
    
    static var hollowContentText: Color { customColor(prefix: "hollow.content.text") }
    
    static var background: Color { customColor(prefix: "background") }
    
    static var hollowCardBackground: Color { customColor(prefix: "hollow.card.background") }
    
    static var hollowCardStarUnselected: Color { customColor(prefix: "hollow.card.star.unselected") }
    
    static var hollowCardStarSelected: Color { customColor(prefix: "hollow.card.star.selected") }

    static var mainPageUnselected: Color { customColor(prefix: "main.page.unselected") }
    
    static var buttonGradient1: Color { customColor(prefix: "button.gradient.1") }
    
    static var buttonGradient2: Color { customColor(prefix: "button.gradient.2") }
    
    static var searchFill: Color { customColor(prefix: "search.fill") }
    
    static var searchButtonBackground: Color { Color("search.button.background") }
    
    static var loginBackgroundPrimary: Color { Color("login.background.primary") }
    
    static var tint: Color { customColor(prefix: "tint") }

    static let hollowCommentQuoteText = Color("hollow.content.comment.quote.text")
}
