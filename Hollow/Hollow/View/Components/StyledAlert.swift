//
//  StyledAlert.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func styledAlert(presented: Binding<Bool>, title: String, message: String?, buttons: [StyledAlert.Button]) -> some View {
        return self
            .modifier(StyledAlertModifier(presented: presented, title: title, message: message, buttons: buttons))
    }
}

struct StyledAlertModifier: ViewModifier {
    @Binding var presented: Bool
    var title: String
    var message: String?
    var buttons: [StyledAlert.Button]

    func body(content: Content) -> some View {
        content
            .onChange(of: presented) { _ in
                guard let topVC = IntegrationUtilities.topViewController() else { return }
                if presented {
                    let newVC = UIHostingController(rootView: StyledAlert(presented: $presented, title: title, message: message, buttons: buttons))
                    newVC.view.backgroundColor = nil
                    newVC.modalPresentationStyle = .overCurrentContext
                    newVC.modalTransitionStyle = .crossDissolve
                    topVC.present(newVC, animated: true)
                }
            }
    }
}

struct StyledAlert: View {
    @Binding var presented: Bool
    
    @State private var scale: CGFloat = 0
    
    @ScaledMetric private var spacing: CGFloat = 14
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) private var secondaryText: CGFloat
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) private var buttonText: CGFloat
    
    var title: String
    var message: String?
    var buttons: [Button]
    
    var body: some View {
        VStack(spacing: spacing) {
            Text(title)
                .font(.headline)
                .padding(.top)
                .padding(.bottom, message == nil || message == "" ? nil : 0)

            if let message = self.message, message != "" {
                Text(message)
                    .font(.system(size: secondaryText))
                    .padding(.bottom)
            }
            ForEach(buttons.indices) { index in
                let button = buttons[index]
                let style = button.style
                SwiftUI.Button(action: {
                    button.action()
                    guard let topVC = IntegrationUtilities.topViewController() else { return }
                    topVC.dismiss(animated: true, completion: {
                        withAnimation { presented = false }
                    })
                }) {
                    Text(button.text)
                        .font(.system(size: buttonText, weight: style.fontWeight))
//                        .fontWeight(style.fontWeight)
                        .foregroundColor(style.accentColor)
                        .horizontalCenter()
                        .padding(.vertical)
                        .background(style.backgroundColor)
                        .cornerRadius(12)
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding(spacing)
        .background(Color.uiColor(.systemBackground))
        .cornerRadius(15)
        .padding()
        .shadow(radius: 10)
        .frame(maxWidth: 300)
        .scaleEffect(scale)
        .horizontalCenter()
        .verticalCenter()
        .background(Color.primary.opacity(0.2).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.25)) {
                scale = 1
            }
        }
    }
    
    struct Button {
        typealias Action = () -> Void
        var text: String
        var style: Style = .default
        var action: Action
        
        static let cancel = Button(text: "Cancel", style: .cancel, action: {})
        
        struct Style {
            var accentColor: Color
            var backgroundColor: Color { accentColor.opacity(0.3) }
            var fontWeight: Font.Weight
            
            static let `default` = Style(accentColor: .blue, fontWeight: .medium)
            static let cancel = Style(accentColor: .secondary, fontWeight: .semibold)
            static let destructive = Style(accentColor: .red, fontWeight: .medium)
            static let hollow = Style(accentColor: .hollowContentVoteGradient1, fontWeight: .medium)
        }
    }
}

struct StyledAlert_Previews: PreviewProvider {
    static var previews: some View {
        StyledAlert(presented: .constant(true), title: "Restore Password", message: "Please send an email using current email address to the contact email to restore your password.", buttons: [
            .init(text: "Default", action: {}),
            .init(text: "Cancel", style: .cancel, action: {}),
            .init(text: "Destructive", style:. destructive, action: {})
        ])
        .background(Color.background)
    }
}
