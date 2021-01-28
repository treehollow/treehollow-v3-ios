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

/// Color extension for customized colors.
extension Color {
    
    static func customColor(prefix: String, colorSet: ColorSet? = nil) -> Color {
        let colorSet = colorSet ?? (Defaults[.hollowType] ?? .thu)
        return Color(prefix + "." + colorSet.description)
    }
    
    
    static var hollowContentVoteGradient1: Color { customColor(prefix: "hollow.content.vote.gradient.1") }
    
    static var hollowContentVoteGradient2: Color { customColor(prefix: "hollow.content.vote.gradient.2") }
    
    static var hollowContentText: Color { customColor(prefix: "hollow.content.text") }
    
    static var background: Color { customColor(prefix: "background") }
    
    static var hollowCardBackground: Color { customColor(prefix: "hollow.card.background") }
    
    static var hollowCardStarUnselected: Color { customColor(prefix: "hollow.card.star.unselected") }
    
    static var hollowCardStarSelected: Color { customColor(prefix: "hollow.card.star.selected") }

    static var mainPageUnselected: Color { customColor(prefix: "main.page.unselected") }
    
    static var mainPageSelected: Color { hollowContentText }
    
    static var mainSearchBarBackground: Color { Color("main.searchbar.background") }
    
    static var mainSearchBarText: Color { mainPageUnselected }
    
    static var mainSearchBarStroke: Color { Color("main.searchbar.stroke") }
    
    static var mainBarButton: Color { mainPageSelected }
    
    static var hollowDetailBackground: Color { hollowCardBackground }
    
    static var buttonGradient1: Color { customColor(prefix: "button.gradient.1") }
    
    static var buttonGradient2: Color { customColor(prefix: "button.gradient.2") }

    static var plainButton: Color { hollowContentText }
    
    static var searchFill: Color { customColor(prefix: "search.fill") }
    
    static var searchButtonBackground: Color { Color("search.button.background") }
    
    static var loginBackgroundPrimary: Color { Color("login.background.primary") }
    
}
