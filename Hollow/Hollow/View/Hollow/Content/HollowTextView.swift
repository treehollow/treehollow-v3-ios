//
//  HollowTextView.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowTextView: View {
    @Binding var text: String
    var body: some View {
        Text(text)
            .hollowContent()
            .leading()
    }
}

struct HollowTextView_Previews: PreviewProvider {
    static var previews: some View {
        HollowTextView(text: .constant("带带，XS👴L，2021年害🈶️冥🐷斗士🉑️害彳亍，👼👼宁❤美🍜，美🍜爱宁🐴，84坏94👄，8👀👀宁美👨早⑨8配和我萌种🌹家√线？我👀宁⑨④太⑨站不⑦来，④⭕＋🇩🇪🐶东西，宁美👨，选个戏子当粽子🚮的🍜＋。墙🍅好东西批爆，⑨④🍚📃宁这样🇩🇪傻🐶出去丢种🌹＋脸，举报三连8送🐢vans了"))
    }
}
