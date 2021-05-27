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
    func swipeToDismiss(presented: Binding<Bool>, transition: AnyTransition = .move(edge: .trailing)) -> some View {
        self.modifier(SwipeToDismiss(presented: presented, transition: transition))
    }
}

fileprivate struct SwipeToDismiss: ViewModifier {
    @Binding var presented: Bool
    @State var offset: CGFloat = 0
    @State var disableScroll = false
    let screenWidth = UIScreen.main.bounds.size.width
    let transition: AnyTransition
    
    func body(content: Content) -> some View {
        content
//            .cornerRadius(min(offset / 5, UIScreen.main.displayCornerRadius ?? 20))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        // 12 is less than the standard padding
                        if value.translation.width >= 0 && value.startLocation.x <= 12 {
                            offset = value.translation.width
                        }
                    })
                    .onEnded { value in
                        let predictedPosition = value.predictedEndLocation.x
                        if (predictedPosition > screenWidth * 3 / 4 || value.location.x > screenWidth * 2 / 3) &&
                            offset > 0 &&
                            predictedPosition > value.location.x {
                            let speed = Double((predictedPosition - value.location.x) / screenWidth)
                            withAnimation(Animation.easeOut(duration: 0.1).speed(min(max(speed, 0.4), 0.7))) {
                                presented = false
                            }
                        } else {
                            withAnimation(.defaultSpring) {
                                offset = 0
                            }
                        }
                        
                    }
            )
            .onAppear { offset = 0 }
            .transition(transition)

    }
}
