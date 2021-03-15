//
//  HollowCommentInputView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowCommentInputView: View {
    @ObservedObject var store: HollowDetailStore
    @State var keyboardShown = false
    @State var showImagePicker = false
    @State private var viewSize: CGSize = .zero
    
    @GestureState var dragOffset: CGFloat = 0
    
    @ScaledMetric var vstackSpacing: CGFloat = ViewConstants.inputViewVStackSpacing
    @ScaledMetric(wrappedValue: ViewConstants.plainButtonFontSize) var buttonFontSize: CGFloat
    @ScaledMetric var buttonWidth: CGFloat = 37
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    @ScaledMetric(wrappedValue: 30, relativeTo: .body) var body30: CGFloat
    @ScaledMetric(wrappedValue: 17, relativeTo: .body) var editorFontSize: CGFloat
    
    @Namespace var animation
    
    var transitionAnimation: Animation?
    var replyToName: String
    
    var hasImage: Bool { store.compressedImage != nil }
    var hideComponents: Bool { keyboardShown }
    
    var contentValid: Bool { store.text != "" || store.compressedImage != nil }
    

    
    var body: some View {
        VStack(spacing: vstackSpacing) {
            HStack {
                BarButton(action: { withAnimation { store.replyToIndex = -2 }}, systemImageName: "xmark")

                Spacer()
                let sendingText = NSLocalizedString("COMMENT_INPUT_SEND_BUTTON_SENDING", comment: "")
                let sendCommentText = NSLocalizedString("COMMENT_INPUT_SEND_BUTTON_SEND_POST", comment: "")
                
                MyButton(action: {
                    store.sendComment()
                    hideKeyboard()
                }, transitionAnimation: transitionAnimation) {
                    Text(store.isSendingComment ? sendingText + "..." : sendCommentText)
                        .modifier(MyButtonDefaultStyle())
                }
                .disabled(!contentValid)
            }
            
            imageView
            
            let placeholder = NSLocalizedString("COMMENT_INPUT_REPLY_TO_PREFIX", comment: "") + replyToName
            
            let bindingText = Binding(
                get: { store.text },
                set: { store.text = $0 }
            )
            HollowInputTextEditor(text: bindingText, editorEditing: .constant(false), placeholder: placeholder, receiveCallback: false)
                .accentColor(.tint)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .frame(height: editorFontSize * 10)
            
            HStack {
                if !keyboardShown { Spacer() }
                imageButton
                if keyboardShown {
                    Spacer()
                    MyButton(action: self.hideKeyboard, transitionAnimation: transitionAnimation) {
                        Text("INPUTVIEW_TEXT_EDITOR_DONE_BUTTON")
                            .font(.system(size: buttonFontSize, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color.hollowCardBackground)
        .roundedCorner(12)
        .padding()
        .shadow(radius: 12)
        .animation(transitionAnimation)
        
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in withAnimation { keyboardShown = true }}
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in withAnimation { store.objectWillChange.send() }}
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in withAnimation { keyboardShown = false }}
        .modifier(ImagePickerModifier(presented: $showImagePicker, image: $store.image))
        .onChange(of: store.image) { _ in store.compressImage() }
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    if value.translation.height > 0 {
                        state = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.predictedEndTranslation.height > viewSize.height * 2 / 3 {
                        store.replyToIndex = -2
                    }
                }
        )
        .disabled(store.isSendingComment || store.isLoading)
        .modifier(GetSize(size: $viewSize))
    }
}

extension HollowCommentInputView {
    // Please keep in sync with HollowInputView's `imageButton`
    var imageButton: some View {
        ZStack {
            Color.background.aspectRatio(1, contentMode: .fit)
            
            Button(action: { withAnimation {
//                editorEditing = false
                self.hideKeyboard()
                if !hasImage || !hideComponents {
                    showImagePicker = true
                }
            }}) {
                if hasImage { ZStack {
                    if hideComponents {
                        Image(uiImage: store.compressedImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 1)
                            .matchedGeometryEffect(id: "photo", in: animation)
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(Color.hollowContentText)
                    }
                }
                } else {
                    Image(systemName: "photo")
                }
                
            }
            
        }
        .foregroundColor(.hollowContentText)
        .circularButton(width: buttonWidth)
        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(.background))

    }
    
    // Please keep in sync with HollowInputView's `imageView`
    var imageView: some View { Group {
        if let image = store.compressedImage, !hideComponents {
            Image(uiImage: image)
                .antialiased(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .roundedCorner(4)
                .overlay(
                    Button(action: { withAnimation { store.compressedImage = nil }}) {
                        ZStack {
                            Blur().frame(width: body30, height: body30).clipShape(Circle())
                            Image(systemName: "xmark")
                                .dynamicFont(size: 14, weight: .semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(body10)
                    }
                    .top()
                    .trailing()
                )
                .overlay(
                    Text(NSLocalizedString("INPUTVIEW_IMAGE_SIZE_LABEL", comment: "") + ": \(store.imageSizeInformation ?? "??")")
                        .fontWeight(.semibold)
                        .font(.footnote)
                        .padding(8)
                        .blurBackground()
                        .roundedCorner(8)
                        .bottom()
                        .trailing()
                        .padding(body10)
                )
                .zIndex(1)
                .matchedGeometryEffect(id: "photo", in: animation)
        } else if let image = store.image, !hideComponents {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.uiColor(.systemFill))
                .aspectRatio(image.size.width / image.size.height, contentMode: .fit)
                .overlay(
                    Text(NSLocalizedString("INPUTVIEW_IMAGE_COMPRESSING_LABEL", comment: "") + "...")
                        .fontWeight(.semibold)
                        .font(.footnote)
                )
        }}
    }
}
