//
//  Spinner.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct Spinner: View {
    @State var progress: Double = 0.6
    @State var isLoading = false
    var color: Color
    var desiredWidth: CGFloat
    var close: Bool = false
    let strokeScaleFactor: CGFloat = 0.2
    var body: some View {
        CircularPathProgressView(progress: $progress, color: color, lineWidth: desiredWidth * strokeScaleFactor)
            .rotationEffect(Angle(degrees: isLoading ? 0 : 360), anchor: .center)
            .padding(.all, desiredWidth * strokeScaleFactor)
            .frame(width: desiredWidth * (1 + strokeScaleFactor), height: desiredWidth * (1 + strokeScaleFactor))
            .onAppear {
                withAnimation(.spring()) {
                    let _ = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { _ in
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
                .animation(.spring())
        }
    }
    
}

struct Spinner_Previews: PreviewProvider {
    static var previews: some View {
        Spinner(color: .blue, desiredWidth: 45)
    }
}
