//
//  Blur.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/27.
//  Copyright © 2021 treehollow. All rights reserved.
//


import SwiftUI

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

extension View {
    func blurBackground(style: UIBlurEffect.Style = .systemUltraThinMaterial) -> some View {
        return self
            .background(Blur(style: style).edgesIgnoringSafeArea(.all))
    }
}
