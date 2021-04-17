//
//  View+onClickGesture.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func onClickGesture(lightEffect: Bool = true, perform action: @escaping () -> Void) -> some View {
        #if targetEnvironment(macCatalyst)
        if lightEffect {
            Button(action: action) { self }
                .buttonStyle(PlainButtonStyle())
        } else {
            Button(action: action) { self }
        }
        #else
        self.onTapGesture(perform: action)
        #endif
    }
}

fileprivate struct CustomButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        print("herehere")
        configuration.trigger()
        return configuration.label
    }
    
}
