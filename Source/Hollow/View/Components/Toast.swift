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
    
    var views = [(UUID, UIView)]()
    
    func show(configuration: Toast.Configuration) {
        let id = UUID()
        let toastView = Toast(
            configuration: configuration,
            presented: Binding(
                get: { true },
                set: { presented in if !presented { self.removeFromScreen(id: id) }}
            )
        )
        let uiView = UIHostingController(rootView: toastView).view!
        guard let window = IntegrationUtilities.keyWindow() else { return }
        uiView.backgroundColor = nil
        window.addSubview(uiView)
        
        // Use auto layout to position the view.
        uiView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uiView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            uiView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            uiView.widthAnchor.constraint(equalTo: window.widthAnchor),
        ])
        views.forEach({ $0.1.removeFromSuperview() })
        views = []
        views.append((id, uiView))
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
                .dynamicFont(size: 22, weight: .semibold)
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
        
        .onClickGesture {
            let title = configuration.message.title == nil || configuration.message.title == "" ?
                configuration.message.body ?? "" :
                configuration.message.title ?? ""
            
            let body = configuration.message.title == nil || configuration.message.title == "" ?
                nil : configuration.message.body

            presentStyledAlert(title: title, message: body, buttons: [.ok])
        }
        
        .onAppear {
            withAnimation(.spring()) {
                opacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring()) {
                    self.opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    presented = false
                }
            }
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
    
    struct Configuration {
        var message: (title: String?, body: String?)
        var style: Style
        
        static func success(title: String?, body: String?) -> Configuration {
            return Configuration(message: (title, body), style: .success)
        }
        
        static func error(title: String?, body: String?) -> Configuration {
            return Configuration(message: (title, body), style: .error)
        }

    }
}
