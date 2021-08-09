//
//  HollowInputView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import UniformTypeIdentifiers

struct HollowInputView: View {
    @ObservedObject var inputStore: HollowInputStore
    
    @State var editorEditing: Bool = false
    @State var keyboardShown = false
    @State var showImagePicker = false
    @State var showErrorAlert = false
    @State var showVoteOptionsAlert = false
    @State var hash = AvatarGenerator.hash(postId: Int.random(in: 0...200), name: "liang2kl")
    
    @ScaledMetric var avatarWidth: CGFloat = 37
    @ScaledMetric var vstackSpacing: CGFloat = ViewConstants.inputViewVStackSpacing
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
    @ScaledMetric(wrappedValue: 30, relativeTo: .body) var body30: CGFloat
    @ScaledMetric(wrappedValue: ViewConstants.plainButtonFontSize) var buttonFontSize: CGFloat
    
    @Namespace var animation
    var buttonAnimationNamespace: Namespace.ID?
    
    var hasVote: Bool { inputStore.voteInformation != nil }
    var hasImage: Bool { inputStore.compressedImage != nil }
    var isCompressing: Bool { inputStore.image != nil && inputStore.compressedImage == nil }
    var hideComponents: Bool { keyboardShown }
    var voteValid: Bool {
        inputStore.voteInformation == nil || inputStore.voteInformation!.valid
    }
    var textValid: Bool { inputStore.text.count <= 10000 }
    var contentValid: Bool {
        if !voteValid { return false }
        if isCompressing { return false }
        if inputStore.text == "" { return hasImage && !hasVote }
        return textValid
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BarButton(action: {
                    withAnimation(.defaultSpring) { inputStore.presented.wrappedValue = false }
                    if inputStore.selfDismiss { dismissSelf() }
                }, systemImageName: "xmark")
                Spacer()
                
                let sendingText = NSLocalizedString("INPUTVIEW_SEND_BUTTON_SENDING", comment: "")
                let sendPostText = NSLocalizedString("INPUTVIEW_SEND_BUTTON_SEND_POST", comment: "")
                MyButton(action: inputStore.sendPost) {
                    Text(inputStore.sending ? sendingText + "..." : sendPostText)
                        .modifier(MyButtonDefaultStyle())
                }
                .disabled(!contentValid)
            }
            .padding(.horizontal)
            .padding(.top, vstackSpacing)
            
            VStack(spacing: vstackSpacing) {
                HollowInputAvatar(avatarWidth: avatarWidth, hash: hash)
                imageView
                
                VStack(spacing: 0) {
                    let text = NSLocalizedString("INPUT_EDITOR_PLACEHOLDER", comment: "")
                    
                    HollowInputTextEditor(text: $inputStore.text, placeholder: text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .frame(minHeight: 40)
                        .layoutPriority(1)
                    editorAccessoryView
                }
                voteView
                footerView
            }
            .padding()
            .background(
                Color.hollowCardBackground
                    .roundedCorner(12)
                    .conditionalMatchedGeometryEffect(id: "float.button", in: buttonAnimationNamespace)
            )
            .padding()
        }
        .onDrop(of: ["public.image"], isTargeted: nil) { providers in
            return inputStore.handleDrop(providers: providers)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in withAnimation { keyboardShown = true }}
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in withAnimation { keyboardShown = false }}
        .background(
            Color.background
                .proposedCornerRadius()
                .proposedIgnoringSafeArea()
        )
        .modifier(ImagePickerModifier(presented: $showImagePicker, image: $inputStore.image))
        .onChange(of: inputStore.image) { _ in inputStore.compressImage() }
        .styledAlert(
            presented: $showVoteOptionsAlert,
            title: NSLocalizedString("INPUTVIEW_VOTE_REMOVE_ALL_ALERT_TITLE", comment: ""),
            message: NSLocalizedString("INPUTVIEW_VOTE_REMOVE_ALL_ALERT_MESSAGE", comment: ""),
            buttons: [
                .init(
                    text: NSLocalizedString("INPUTVIEW_VOTE_REMOVE_ALL_ALERT_BUTTON_CONFIRM", comment: ""),
                    action: { withAnimation { inputStore.voteInformation = nil }}),
                .cancel
            ]
        )
        .modifier(ErrorAlert(errorMessage: $inputStore.errorMessage))
        .accentColor(.tint)
        .disabled(inputStore.sending)
    }
}
