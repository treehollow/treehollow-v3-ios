//
//  HollowCommentInputView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowCommentInputView: View {
    @ObservedObject var store = HollowCommentInputStore()
    
    @State private var editorEditing = false
    @State var keyboardShown = false
    @State var showImagePicker = false
    
    @ScaledMetric var vstackSpacing: CGFloat = ViewConstants.inputViewVStackSpacing
    @ScaledMetric(wrappedValue: ViewConstants.plainButtonFontSize) var buttonFontSize: CGFloat
    @ScaledMetric var buttonWidth: CGFloat = 37
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
    @ScaledMetric(wrappedValue: 30, relativeTo: .body) var body30: CGFloat
    @ScaledMetric(wrappedValue: 17, relativeTo: .body) var editorFontSize: CGFloat
    
    @Namespace var animation
    
    var hasImage: Bool { store.compressedImage != nil }
    var hideComponents: Bool { keyboardShown }
    
    var body: some View {
        VStack(spacing: vstackSpacing) {
            imageView
            
            CustomTextEditor(text: $store.text, editing: $editorEditing, modifiers: { $0 })
                .overlayDoneButtonAndLimit(
                    editing: $editorEditing,
                    textCount: store.text.count,
                    limit: 10000,
                    buttonFontSize: buttonFontSize
                )
                .overlay(Group { if store.text == "" {
                    let text = NSLocalizedString("COMMENT_INPUT_EDITOR_PLACEHOLDER", comment: "")
                    Text(text + "...")
                        .foregroundColor(.uiColor(.systemFill))
                }})
                .frame(height: editorFontSize * 7)
            imageButton.trailing()
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in withAnimation { keyboardShown = true }}
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in withAnimation { keyboardShown = false }}
        .modifier(ImagePickerModifier(presented: $showImagePicker, image: $store.image))
        .onChange(of: store.image) { _ in store.compressImage() }
    }
}

extension HollowCommentInputView {
    // Please keep in sync with HollowInputView's `imageButton`
    var imageButton: some View {
        ZStack {
            Color.background.aspectRatio(1, contentMode: .fit)
            
            Button(action: { withAnimation {
                editorEditing = false
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
                .cornerRadius(4)
                .overlay(
                    Button(action: { withAnimation { store.compressedImage = nil }}) {
                        ZStack {
                            Blur().frame(width: body30, height: body30).clipShape(Circle())
                            Image(systemName: "xmark")
                                .font(.system(size: body15, weight: .semibold))
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
                        .cornerRadius(8)
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

#if DEBUG
struct HollowCommentInputView_Previews: PreviewProvider {
    static var previews: some View {
        HollowCommentInputView()
    }
}
#endif
