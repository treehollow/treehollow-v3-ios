//
//  CustomTextEditor.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/7.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

/// Helper modifier for wrapping `TextEditor` inside `TextEditorWrapper`.
///
/// Modify the `TextEditor` first, like applying `fixedSize()`, before applying this modifier.
struct CustomTextEditorModifier: ViewModifier {
    @Binding var text: String
    @Binding var editing: Bool
    func body(content: Content) -> some View {
        TextEditorWrapper(text: $text, editing: $editing) { content }
    }
}

/// Wrapper for text editor to access the internal `UITextView` and enjoy
/// the full functionality of UIKit.
///
/// The content must contain `TextEditor`.
struct TextEditorWrapper<Content>: View where Content: View {
    @Binding var text: String
    @Binding var editing: Bool

    let content: () -> Content
    
    var body: some View {
        TextEditorRepresentable(text: $text, editing: $editing, content: content())
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
    var ready = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if ready { return } // avoid running more than once
        ready = true
        
        textView = findUITextView(view: view)
        textView?.backgroundColor = nil
        textView?.delegate = self
//        textView?.isEditable = false
//        textView?.isScrollEnabled = false
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
        text.wrappedValue = textView.text
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewEditing.wrappedValue = true
    }
}

func setImage(array: inout [PostData], image: UIImage, index: Int) {
    array[index].hollowImage?.image = image
}
func testPerformRequest(completion: (String) -> Void) {
    
    var resultData: [PostData]
    
    resultData = [testPostData2]
    
    setImage(array: &resultData, image: .init(), index: 0)
}
