//
//  MyButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct MyButton<Content>: View where Content: View {
    var action: () -> Void
    var gradient: LinearGradient
    var transitionAnimation = Animation.easeInOut
    var content: () -> Content
    var body: some View {
        Button(action: action) {
            content()
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(gradient)
                .cornerRadius(6)
                .animation(transitionAnimation)
        }
    }
}

struct MyButton_Previews: PreviewProvider {
    static var previews: some View {
        MyButton(action: {}, gradient: .vertical(gradient: .button), content: {Text("搜索").font(.system(size: 12, weight: .bold)).foregroundColor(.white)})
            .colorScheme(.dark)
    }
}
