//
//  CustomTextEditor.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/7.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

/// Wrapper for text editor to access the internal `UITextView` and enjoy
/// the full functionality of UIKit.
struct CustomTextEditor<Content>: View where Content: View {
    @Binding var text: String
    @Binding var editing: Bool

    let modifiers: (TextEditor) -> Content
    
    var body: some View {
        TextEditorRepresentable(text: $text, editing: $editing, content: modifiers(TextEditor(text: $text)))
    }
}

fileprivate struct TextEditorRepresentable<Content>: UIViewControllerRepresentable where Content: View {
    typealias UIViewControllerType = TextEditorUIHostingController<Content>
    
    var text: Binding<String>
    var editing: Binding<Bool>
    let content: Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TextEditorRepresentable<Content>>) -> TextEditorUIHostingController<Content> {
        return TextEditorUIHostingController(text: text, textViewEditing: editing, rootView: self.content)
    }
    
    func updateUIViewController(_ uiViewController: TextEditorUIHostingController<Content>, context: UIViewControllerRepresentableContext<TextEditorRepresentable<Content>>) {
        // necessary here as we need to update the `rootView` property
        // when SwiftUI updates the view (the property `content`)
        uiViewController.rootView = content
        if !editing.wrappedValue {
            uiViewController.textView?.endEditing(true)
        }
    }
}

fileprivate class TextEditorUIHostingController<Content>: UIHostingController<Content>, UITextViewDelegate where Content: View {
    var text: Binding<String>
    var textViewEditing: Binding<Bool>
    var textView: UITextView?
    
    init(text: Binding<String>, textViewEditing: Binding<Bool>, rootView: Content) {
        self.text = text
        self.textViewEditing = textViewEditing
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setUITextView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setUITextView()
    }
    
    func setUITextView() {
        if textView != nil { return }
        
        textView = findUITextView(view: view)
        textView?.backgroundColor = nil
        
        // Once we set the delegate to `self`, some of the original functionality
        // of SwiftUI's TextEditor will be lost (e.g. the @Binding text will not
        // change). Thus we need to implement by ourselves (using delegate methods).
        textView?.delegate = self
    }
    
    private func findUITextView(view: UIView) -> UITextView? {
        if view.isKind(of: UITextView.self) { return view as? UITextView }
        
        for subView in view.subviews {
            if let textView = findUITextView(view: subView) {
                view.backgroundColor = nil
                return textView
            }
        }
        return nil
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            withAnimation { self.text.wrappedValue = textView.text }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            withAnimation { self.textViewEditing.wrappedValue = true }
        }
    }
}
