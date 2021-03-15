//
//  StyledAlert.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func styledAlert(presented: Binding<Bool>, title: String, message: String?, buttons: [StyledAlertButton]) -> some View {
        return self
            .modalPresent(presented: presented, presentationStyle: .overFullScreen, transitionStyle: .crossDissolve) {
                StyledAlert(presented: presented, title: title, message: message, buttons: buttons)
            }
    }
    
    func styledAlert<Content: View>(presented: Binding<Bool>, title: String, message: String?, buttons: [StyledAlertButton], accessoryView: @escaping () -> Content) -> some View {
        return self
            .modalPresent(presented: presented, presentationStyle: .overFullScreen, transitionStyle: .crossDissolve) {
                AccessoryStyledAlert(presented: presented, title: title, message: message, buttons: buttons, accessoryView: accessoryView)
            }
    }
}

struct StyledAlert: View {
    fileprivate typealias StyledAlertView = _StyledAlert<EmptyView>
    @Binding var presented: Bool
    // Whether to dismiss itself
    var selfDismiss = false

    var title: String
    var message: String?
    var buttons: [StyledAlertButton]

    var body: some View {
        StyledAlertView(presented: $presented, selfDismiss: selfDismiss, title: title, message: message, buttons: buttons)
    }
}

struct AccessoryStyledAlert<Content: View>: View {
    fileprivate typealias StyledAlertView = _StyledAlert<Content>
    
    @Binding var presented: Bool
    // Whether to dismiss itself
    var selfDismiss = false

    var title: String
    var message: String?
    
    var buttons: [StyledAlertButton]

    var accessoryView: () -> Content

    var body: some View {
        StyledAlertView(presented: $presented, selfDismiss: selfDismiss, title: title, message: message, buttons: buttons, accessoryView: accessoryView)
    }

}

fileprivate struct _StyledAlert<Content: View>: View {
    @Binding var presented: Bool
    
    @State private var scale: CGFloat = 0.3
    
    // Whether to dismiss itself
    var selfDismiss = false
    
    @ScaledMetric private var spacing: CGFloat = 14
    
    @Environment(\.colorScheme) private var colorScheme

    var title: String
    var message: String?
    var buttons: [StyledAlertButton]
    var accessoryView: (() -> Content)? = nil
    
    var body: some View {
        VStack(spacing: spacing) {
            Text(title)
                .font(.headline)
                .padding(.top)
                .padding(.bottom, message == nil || message == "" ? nil : 0)

            if let message = self.message, message != "" {
                Text(message)
                    .dynamicFont(size: 14)
                    .padding(.bottom)
            }
            
            accessoryView?()
            
            ForEach(buttons.indices) { index in
                let button = buttons[index]
                let style = button.style
                SwiftUI.Button(action: {
                    button.action()
                    if selfDismiss {
                        dismissSelf()
                    } else {
                        withAnimation { presented = false }
                    }
                }) {
                    Text(button.text)
                        .dynamicFont(size: 15, weight: style.fontWeight)
                        .foregroundColor(style.accentColor)
                        .horizontalCenter()
                        .padding(.vertical)
                        .background(style.backgroundColor)
                        .roundedCorner(12)
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding(spacing)
        .background(Color.uiColor(colorScheme == .light ? .systemBackground : .tertiarySystemBackground))
        .roundedCorner(15)
        .padding()
        .shadow(radius: 11)
        .frame(maxWidth: 310)
        .scaleEffect(scale)
        .horizontalCenter()
        .verticalCenter()
        .background(Color.black.opacity(0.2).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.25)) {
                scale = 1
            }
        }
    }
    
}

struct StyledAlertButton {
    typealias Action = () -> Void
    var text: String
    var style: Style = .default
    var action: Action
    
    static func cancel(action: @escaping Action) -> Self {
        return Self(text: NSLocalizedString("ALERT_CANCEL_BUTTON", comment: ""), style: .cancel, action: action)
    }
    static let cancel = Self(text: NSLocalizedString("ALERT_CANCEL_BUTTON", comment: ""), style: .cancel, action: {})
    static let ok = Self(text: NSLocalizedString("ALERT_OK_BUTTON", comment: ""), style: .cancel, action: {})
    
    struct Style {
        var accentColor: Color
        var backgroundColor: Color { accentColor.opacity(0.3) }
        var fontWeight: Font.Weight
        
        static let `default` = Style(accentColor: .hollowContentVoteGradient1, fontWeight: .medium)
        static let cancel = Style(accentColor: .secondary, fontWeight: .semibold)
        static let destructive = Style(accentColor: .red, fontWeight: .medium)
    }
}
