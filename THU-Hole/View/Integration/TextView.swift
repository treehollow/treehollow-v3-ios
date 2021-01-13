//
//  TextView.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/12.
//

import SwiftUI

final class TextView: UIViewControllerRepresentable {
    
    public init(attributedString: Binding<NSAttributedString>) {
        self._attributedString = attributedString
    }
    
    @Binding var attributedString: NSAttributedString
    var viewController: UIViewController!
    var textView: UITextView!
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIViewController()
        let textView = UITextView()
        self.viewController = controller
        self.textView = textView
        textView.backgroundColor = .clear
        textView.contentInset = .zero
        textView.textContainerInset = .zero
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.attributedText = attributedString
        controller.view.addSubview(textView)
        
        // Legacy Auto Layout
        let viewLayout = controller.view.safeAreaLayoutGuide
        textView.leadingAnchor.constraint(equalTo: viewLayout.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: viewLayout.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: viewLayout.topAnchor).isActive = true

        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if let textView = self.textView {
            uiViewController.preferredContentSize = CGSize(width: uiViewController.preferredContentSize.width, height: textView.contentSize.height)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ vc: TextView) {
            self.parent = vc
        }
        
    }

}
