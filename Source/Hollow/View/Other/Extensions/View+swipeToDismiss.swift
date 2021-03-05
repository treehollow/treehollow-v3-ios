//
//  View+swipeToDismiss.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func swipeToDismiss(presented: Binding<Bool>) -> some View {
        self.modifier(SwipeToDismiss(presented: presented))
    }
}

fileprivate struct SwipeToDismiss: ViewModifier {
    @Binding var presented: Bool
    @State var offset: CGFloat = 0
    @State var disableScroll = false
    let screenWidth = UIScreen.main.bounds.size.width
    
    func body(content: Content) -> some View {
        content
            .transition(.move(edge: .trailing))
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
                            print(speed)
                            withAnimation(Animation.easeOut(duration: 0.1).speed(min(max(speed, 0.4), 0.7))) {
                                presented = false
                                offset = 0
                            }
                        } else {
                            withAnimation(.spring(response: 0.2)) {
                                offset = 0
                            }
                        }
                        
                    }
            )
            .onAppear { offset = 0 }
    }
}
