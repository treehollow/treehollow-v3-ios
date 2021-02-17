//
//  HollowInputView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowInputView: View {
    @ObservedObject var inputStore: HollowInputStore
    
    @State var editorEditing: Bool = false
    @State var keyboardShown = false
    @State var showImagePicker = false
    @State var showAlertIndex: AlertIndex?
    
    @ScaledMetric var avatarWidth: CGFloat = 37
    @ScaledMetric var vstackSpacing: CGFloat = 12
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
    @ScaledMetric(wrappedValue: 30, relativeTo: .body) var body30: CGFloat
    @ScaledMetric(wrappedValue: ViewConstants.plainButtonFontSize) var buttonFontSize: CGFloat
    
    @Namespace var animation
    
    var hasVote: Bool { inputStore.voteInformation != nil }
    var hasImage: Bool { inputStore.compressedImage != nil }
    var hideComponents: Bool { keyboardShown }
    var voteValid: Bool {
        inputStore.voteInformation == nil || inputStore.voteInformation!.valid
    }
    var textValid: Bool { inputStore.text.count <= 10000 }
    var contentValid: Bool {
        if !voteValid { return false }
        if inputStore.text == "" { return hasImage && !hasVote }
        return textValid
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BarButton(action: { withAnimation { inputStore.presented.wrappedValue = false }}, systemImageName: "xmark")
                Spacer()
                MyButton(action: inputStore.sendPost) {
                    Text(inputStore.sending ? "Sending" + "..." : "Send Post")
                        .modifier(MyButtonDefaultStyle())
                }
                .disabled(!contentValid)
            }
            .padding(.horizontal)
            
            VStack(spacing: vstackSpacing) {
                avatar
                imageView
                editorView
                voteView
                footerView
            }
            .padding()
            .background(Color.hollowCardBackground)
            .cornerRadius(12)
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in withAnimation { keyboardShown = true }}
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in withAnimation { keyboardShown = false }}
        .background(Color.background.ignoresSafeArea())
        .modifier(ImagePickerModifier(presented: $showImagePicker, image: $inputStore.image))
        .onChange(of: inputStore.image) { _ in inputStore.compressImage() }
        .onChange(of: inputStore.errorMessage?.title) { title in if title != nil { showAlertIndex = .error }}
        .alert(item: $showAlertIndex) { index in
            switch index {
            case .error:
                return ErrorAlert.alert(errorMessage: $inputStore.errorMessage) ?? Alert(title: Text("Unknown error!"))
            case .vote:
                return Alert(
                    title: Text("The number of the options must be no less than 2"),
                    message: Text("Do you want to remove all the options?"),
                    primaryButton: .cancel(),
                    secondaryButton: .default(Text("Yes"), action: { withAnimation { inputStore.voteInformation = nil }})
                )
            }
        }
        .accentColor(.hollowContentText)
        .disabled(inputStore.sending)
        .modifier(AppModelBehaviour(state: inputStore.appModelState))
    }
}

extension HollowInputView {
    enum AlertIndex: Int, Identifiable {
        case error = 0
        case vote = 1
        
        var id: Int { self.rawValue }
    }
}

#if DEBUG
//struct HollowInputView_Previews: PreviewProvider {
//    static var previews: some View {
////        HollowInputView(presented: .constant(true))
//        //            .background(Color.hollowCardBackground)
//        //            .cornerRadius(12)
//        //            .padding()
//        //            .background(Color.background)
//        //            .colorScheme(.dark)
//    }
//}
#endif
