//
//  Toast.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

class ToastManager {
    static let shared = ToastManager()
    
    private init() {}
    
    // Use an array to store the references if we are to support
    // displaying multiple toasts at the same time
    var views = [(UUID, UIView)]()
    
    func show(configuration: Toast.Configuration) {
        guard configuration.message.title != nil || configuration.message.body != nil else { return }
        let id = UUID()
        let toastView = Toast(
            configuration: configuration,
            presented: Binding(
                get: { true },
                set: { presented in if !presented { self.removeFromScreen(id: id) }}
            )
        )
        guard let uiView = UIHostingController(rootView: toastView).view,
              let window = IntegrationUtilities.keyWindow() else { return }
        
        uiView.backgroundColor = nil
        window.addSubview(uiView)
        
        // Use auto layout to position the view.
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        if configuration.anchor == .bottom {
            uiView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
        } else {
            uiView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
        }
        
        views.forEach({ $0.1.removeFromSuperview() })
        views = [(id, uiView)]
        
        // Feedback
        switch configuration.type {
        case .success: UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .error: UINotificationFeedbackGenerator().notificationOccurred(.error)
        default: break
        }
    }
    
    private func removeFromScreen(id: UUID) {
        guard let view = views.first(where: { $0.0 == id })?.1 else { return }
        view.removeFromSuperview()
    }
}


struct Toast: View {
    var configuration: Toast.Configuration
    
    @State private var opacity: Double = 0
    @Binding var presented: Bool
    
    var body: some View {
        HStack {
            Image(systemName: configuration.style.systemImageName)
                .dynamicFont(size: 20, weight: .semibold, design: .rounded)
            (
                (configuration.message.title == nil || configuration.message.title == "" ?
                    Text("") : Text(configuration.message.title! + " ")
                ).bold() +
                    Text(configuration.message.body ?? "")
            )
            .dynamicFont(size: 15, weight: .semibold, design: .rounded)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .lineLimit(4)
        }
        .foregroundColor(configuration.style.fontColor)
        .padding()
        .padding(.horizontal, 5)
        
        .background(
            RoundedRectangle(cornerRadius: 22.0, style: .continuous)
                .foregroundColor(configuration.style.backgroundColor)
                .shadow(radius: 5)
        )
        .opacity(opacity)
        .padding()
        .padding(.horizontal)
        .animation(.default)
        .transition(.move(edge: .bottom))
        
        .onClickGesture(perform: configuration.onTap ?? dismiss)
        
        .onAppear {
            withAnimation(.spring()) {
                opacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: dismiss)
        }
        
    }
    
    func dismiss() {
        guard presented else { return }
        withAnimation(.spring()) {
            self.opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            presented = false
        }
    }
}

extension Toast {
    struct Style {
        var systemImageName: String
        var fontColor: Color
        var backgroundColor: Color
        
        static let error = Style(systemImageName: "xmark.circle.fill", fontColor: .white, backgroundColor: .red)
        static let success = Style(systemImageName: "checkmark.circle.fill", fontColor: .white, backgroundColor: .hollowContentVoteGradient1)
    }
    
    enum ToastType: Int {
        case success, error, plain
    }
    
    enum Anchor: Int {
        case top, bottom
    }
    
    struct Configuration {
        var message: (title: String?, body: String?)
        var style: Style
        var type: ToastType
        var anchor: Anchor
        var onTap: (() -> Void)?
        
        static func success(title: String?, body: String?, anchor: Anchor = .bottom, onTap: (() -> Void)? = nil) -> Configuration {
            return Configuration(message: (title, body), style: .success, type: .success, anchor: anchor, onTap: onTap)
        }
        
        static func error(title: String?, body: String?, anchor: Anchor = .bottom, onTap: (() -> Void)? = nil) -> Configuration {
            return Configuration(message: (title, body), style: .error, type: .error, anchor: anchor, onTap: onTap)
        }

    }
}
