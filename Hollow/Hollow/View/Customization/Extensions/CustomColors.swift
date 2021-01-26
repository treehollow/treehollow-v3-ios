//
//  CustomColors.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

enum ColorSet: String, Codable {
    case thu = "thu"
    case pku = "pku"
    case other = "other"
}

/// Color extension for customized colors.
extension Color {
    
    fileprivate static func customColor(prefix: String) -> Color {
        let colorSet = Defaults[.uiColorSet] ?? .thu
        return Color(prefix + "." + colorSet.rawValue)
    }
    
    static let hollowContentVoteGradient1 = customColor(prefix: "hollow.content.vote.gradient.1")
    
    static let hollowContentVoteGradient2 = customColor(prefix: "hollow.content.vote.gradient.2")
    
    static let hollowContentText = customColor(prefix: "hollow.content.text")
    
    static let background = customColor(prefix: "background")
    
    static let hollowCardBackground = customColor(prefix: "hollow.card.background")
    
    static let hollowCardStarUnselected = customColor(prefix: "hollow.card.star.unselected")
    
    static let hollowCardStarSelected = customColor(prefix: "hollow.card.star.selected")

    static let mainPageUnselected = customColor(prefix: "main.page.unselected")
    
    static let mainPageSelected = hollowContentText
    
    static let mainSearchBarBackground = customColor(prefix: "main.searchbar.background")
    
    static let mainSearchBarText = mainPageUnselected
    
    static let mainSearchBarStroke = customColor(prefix: "main.searchbar.stroke")
    
    static let mainBarButton = mainPageSelected
    
    static let hollowDetailBackground = hollowCardBackground
}
