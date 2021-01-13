//
//  HoleConfiguration.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/13.
//

import SwiftUI

struct HoleHeaderConfiguration {
    var holeIndex: Int
    var timeString: String
    var tags: [HoleHeaderView.TagView.TagType]
    var compact: Bool
    var starredNumber: Int
    var commentNumber: Int
}

struct HoleCommentHeaderConfiguration {
    var holeIndex: Int
    var timeString: String
    var compact: Bool
}

struct HoleCardConfiguration {
    var headerConfiguration: HoleHeaderConfiguration
    var showHoleContent: Bool {
        return !headerConfiguration.tags.contains(.sex) && !headerConfiguration.tags.contains(.report)
    }
    // TODO: change type `Text` to a universal type
    var texts: [Text]
    var commentConfigurations: [HoleCommentConfiguration]? = nil
}

struct HoleCommentConfiguration {
    // TODO: Alice, Bob, ...
    var headerConfiguration: HoleCommentHeaderConfiguration
    // TODO: change type `Text` to a universal type
    var texts: [Text]
}
