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
                        if value.predictedEndTranslation.width + value.startLocation.x > screenWidth / 2 &&
                            offset > 0 {
                            withAnimation(.easeIn(duration: 0.2)) {
                                presented = false
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.3)) {
                                offset = 0
                            }
                        }
                        
                    }
            )
        
    }
}
