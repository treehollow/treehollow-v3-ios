//
//  View+swipeToDismiss.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    /// Apply a swipe gesture and a moving transition to the view to enable the capacity to
    /// dismiss a view with a swiping gesture.
    func swipeToDismiss(presented: Binding<Bool>, transition: AnyTransition = .hideToBottomTrailing) -> some View {
        self.modifier(SwipeToDismiss(presented: presented, transition: transition))
    }
}

fileprivate struct SwipeToDismiss: ViewModifier {
    @Binding var presented: Bool
    @State var offset: (x: CGFloat, y: CGFloat) = (0, 0)
    @State var scale: CGFloat = 1
    @State var disableScroll = false
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height

    let transition: AnyTransition
    
    func body(content: Content) -> some View {
        content
            .cornerRadiusEnvironment(radius: min(25, 400 * (1 - scale)))
            .compositingGroup()
            .scaleEffect(scale)
            .offset(x: offset.x, y: offset.y)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // 12 is less than the standard padding
                        if value.translation.width >= 0 && value.startLocation.x <= 12 {
                            withAnimation(offset == (0, 0) ? .defaultSpring : nil) {
                                offset.x = offset(for: value.translation.width)
                                offset.y = offset(for: value.translation.height)
                                scale = scale(for: sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2)))
                            }
                        }
                    }
                    .onEnded { value in
                        if offsetExceeded(with: value) {
                            withAnimation {
                                presented = false
                                offset = (0, 0)
                                scale = 1
                            }
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 1)) {
                                offset = (0, 0)
                                scale = 1
                            }
                        }
                        
                    }
            )
            .onAppear {
                offset = (0, 0)
                scale = 1
            }
            .transition(transition)
    }
    
    private func offset(for value: CGFloat) -> CGFloat {
        // y = \sqrt{a*(x+a/4)} - a/2, where a > 0
        // y' = 1 && y(0) = 0
        let a: CGFloat = 200
        let offset = sqrt(a * (abs(value) + a / 4)) - a / 2
        return value > 0 ? offset : -offset
    }
    
    private func scale(for value: CGFloat) -> CGFloat {
        return exp(-0.0003 * value)
    }
    
    private func offsetExceeded(with value: DragGesture.Value) -> Bool {
        let xTranslation = value.translation.width
        let yTranslation = value.translation.height
        let predictedYTranslation = value.predictedEndTranslation.height
        let predictedXTranslation = value.predictedEndTranslation.width
        
        if (predictedXTranslation > screenWidth * 2 / 3 || xTranslation > screenWidth / 2) && predictedXTranslation > -50 {
            return true
        }
        
        if (predictedYTranslation > screenHeight * 2 / 3 || yTranslation > screenHeight / 2) && predictedYTranslation > -50 {
            return true
        }
        
        return false
    }
}
