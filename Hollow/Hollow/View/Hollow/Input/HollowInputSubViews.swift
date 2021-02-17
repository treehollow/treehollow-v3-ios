//
//  HollowInputSubViews.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/13.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension HollowInputView {
    var avatar: some View {
        AvatarWrapper(
            colors: [.buttonGradient1, .background],
            resolution: 4,
            padding: avatarWidth * 0.1,
            // Boom! You've discover a hidden "bug"!
            value: "liang2kl"
        )
        .frame(width: avatarWidth)
        .fixedSize()
        .clipShape(Circle())
        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(.buttonGradient1))
        .leading()
    }
    
    var imageView: some View { Group {
        if let image = inputStore.compressedImage, !hideComponents {
            Image(uiImage: image)
                .antialiased(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(4)
                .overlay(
                    Button(action: { withAnimation { inputStore.compressedImage = nil }}) {
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
                    Text("Size: \(inputStore.imageSizeInformation ?? "??")")
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
        } else if let image = inputStore.image, !hideComponents {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.uiColor(.systemFill))
                .aspectRatio(image.size.width / image.size.height, contentMode: .fit)
                .overlay(
                    Text("Compressing" + "...")
                        .fontWeight(.semibold)
                        .font(.footnote)
                )
        }}
    }
    
    var editorView: some View {
        CustomTextEditor(text: $inputStore.text, editing: $editorEditing) { $0 }
            .overlayDoneButtonAndLimit(
                editing: $editorEditing,
                textCount: inputStore.text.count,
                limit: 10000,
                buttonFontSize: buttonFontSize
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .overlay(Group { if inputStore.text == "" {
                Text("Input text" + "...")
                    .foregroundColor(.uiColor(.systemFill))
            }})
    }
    
    var voteView: some View { Group {
        if let voteInfo = inputStore.voteInformation {
            VStack {
                ForEach(voteInfo.options.indices, id: \.self) { index in
                    let bindingText = Binding<String>(
                        get: { voteInfo.options[index] },
                        set: { inputStore.voteInformation?.options[index] = $0 }
                    )
                    
                    MyTextField(
                        text: bindingText,
                        placeHolder: "Option \(index + 1)",
                        backgroundColor: .background, content: {
                            Button(action: {
                                if voteInfo.options.count == 2 {
                                    showAlertIndex = .vote
                                    return
                                }
                                inputStore.voteInformation?.options.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .accentColor(voteInfo.optionHasDuplicate(voteInfo.options[index]) ? .red : .hollowContentText)
                        }
                    )
                    
                }
                
            }
            .padding(.bottom)
            .onChange(of: inputStore.voteInformation?.options) { options in
                withAnimation {
                    if options?.count == 0 { inputStore.voteInformation = nil }
                }
            }
        }}
    }
    
    var footerView: some View {
        HStack(spacing: body12) {
            Menu(content: {
                Button("None", action: { withAnimation { inputStore.selectedTag = nil }})
                
                ForEach(inputStore.availableTags, id: \.self) { tag in
                    Button(tag, action: { withAnimation { inputStore.selectedTag = tag }})
                }
            }, label: {
                let labelText = inputStore.selectedTag != nil ?
                    "#" + inputStore.selectedTag! : "Select a tag"
                Text(labelText)
                    .modifier(MyButtonDefaultStyle())
                    .defaultButtonStyle()
            })
            .fixedSize()
            Spacer()
            
            imageButton
                .matchedGeometryEffect(id: "select.photo", in: animation)
                // Disable the button when compressing
                .disabled(inputStore.image != nil)
                .layoutPriority(1)
                .fixedSize()
            
            voteButton
                .layoutPriority(1)
                .fixedSize()

        }

        .fixedSize(horizontal: false, vertical: true)

        // Make the buttons feel disabled when sending data.
        // This is implemented in `MyButton` to automatically update
        // when the views are disabled, but here for convenience we
        // just judge by `inputStore.sending`
        .opacity(inputStore.sending ? 0.5 : 1)
    }
    
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
                        Image(uiImage: inputStore.compressedImage!)
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
        .circularButton(width: avatarWidth)
        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(.background))
        
    }
    
    var voteButton: some View {
        // Vote
        ZStack {
            Color.background
            Button(action: { withAnimation {
                if editorEditing {
                    editorEditing = false
                }
                if hasVote { inputStore.voteInformation?.options.append("") }
                else { inputStore.newVote() }
            }}) {
                if hasVote {
                    Image(systemName: "plus")
                        .opacity(inputStore.voteInformation!.options.count == 4 ? 0.3 : 1)
                } else {
                    Image(systemName: "chart.bar.xaxis")
                }
            }
        }
        .disabled(hasVote && inputStore.voteInformation!.options.count == 4)
        .foregroundColor(.hollowContentText)
        .circularButton(width: avatarWidth)
    }

}

extension View {
    func circularButton(width: CGFloat) -> some View {
        return self
            .frame(width: width, height: width)
            .clipShape(Circle())
    }
}

extension CustomTextEditor {
    func overlayDoneButtonAndLimit(
        editing: Binding<Bool>,
        textCount: Int,
        limit: Int,
        buttonFontSize: CGFloat) -> some View {
        let textValid = textCount <= limit
        return VStack {
            self
            HStack(alignment: .bottom) {
                if !textValid { HStack(spacing: 0) {
                    Text("\(textCount)")
                        .font(.footnote)
                        .foregroundColor(.red)
                    Text(" / \(limit)")
                        .font(.footnote)
                }}
                
                if editing.wrappedValue {
                    MyButton(action: { editing.wrappedValue = false }) {
                        Text("Done")
                            .font(.system(size: buttonFontSize, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .bottom()
            .trailing()
            .padding(.bottom, 5)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
