//
//  UIKitSearchBar.swift
//  UIKitSearchBar
//
//  Created by liang2kl on 2021/8/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct UIKitSearchBar: UIViewRepresentable {
    @Binding var text: String
    var prompt: String? = nil
    
    func makeUIView(context: Context) -> UISearchTextField {
        let searchField = UISearchTextField()
        searchField.tintColor = UIColor(Color.tint)
        searchField.placeholder = prompt
        searchField.addTarget(context.coordinator, action: #selector(context.coordinator.textDidChange(_:)), for: .editingChanged)
        searchField.delegate = context.coordinator
        searchField.returnKeyType = .done
        searchField.becomeFirstResponder()
        return searchField
    }
    
    func updateUIView(_ uiView: UISearchTextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return .init(self)
    }

    class Coordinator: NSObject, UISearchTextFieldDelegate {
        var parent: UIKitSearchBar
        
        init(_ parent: UIKitSearchBar) {
            self.parent = parent
        }
        
        @objc func textDidChange(_ field: UISearchTextField) {
            withAnimation { parent.text = field.text ?? "" }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}
