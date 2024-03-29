//
//  Spinner.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct Spinner: View {
    
    @State private var progress: Double = 0.6
    @State private var isLoading = false
    @State private var timer: Timer?
    var color: Color
    var desiredWidth: CGFloat
    var close: Bool = false
    private let strokeScaleFactor: CGFloat = 0.2
    var body: some View {
        CircularPathProgressView(progress: $progress, color: color, lineWidth: desiredWidth * strokeScaleFactor)
            .rotationEffect(Angle(degrees: isLoading ? 0 : 360), anchor: .center)
            .padding(.all, desiredWidth * strokeScaleFactor)
            .frame(width: desiredWidth * (1 + strokeScaleFactor), height: desiredWidth * (1 + strokeScaleFactor))
            .onAppear {
                guard timer == nil else { return }
                timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { _ in
                    withAnimation(.spring()) {
                        switch progress {
                        case 0.3: progress = 0.6
                        case 0.6: progress = close ? 1.0 : 0.3
                        case 1: progress = 0.3
                        default: progress = 0.6
                        }
                    }
                }
                withAnimation(Animation.linear(duration: 0.75).repeatForever(autoreverses: false)) {
                    isLoading.toggle()
                }
            }
            .onDisappear { timer?.invalidate() }
    }
    
    struct CircularPathProgressView: View {
        @Binding var progress: Double
        var color: Color
        var lineWidth: CGFloat
        var body: some View {
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .rotation(.init(degrees: -90), anchor: .center)
                .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
                .animation(.linear, value: progress)
        }
    }
    
}
