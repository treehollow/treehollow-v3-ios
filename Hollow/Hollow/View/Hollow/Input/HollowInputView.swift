//
//  HollowInputView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowInputView: View {
    @ObservedObject var inputStore = HollowInputStore()
    
    @State private var editing: Bool = false
    @State private var showImagePicker = false
    @State private var showVoteAlert = false
    
    @ScaledMetric var avatarWidth: CGFloat = 37
    @ScaledMetric var vstackSpacing: CGFloat = 12
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat

    @Namespace var animation
    
    var hasVote: Bool { inputStore.voteInformation != nil }
    var hasImage: Bool { inputStore.image != nil }
    
    var body: some View {
        VStack(spacing: vstackSpacing) {
            Image("test.avatar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: avatarWidth)
                .clipShape(Circle())
                .leading()
            if let image = inputStore.image, !editing {
                Image(uiImage: image)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(4)
                    .matchedGeometryEffect(id: "photo", in: animation)
            }
            CustomTextEditor(text: $inputStore.text, editing: $editing) { $0 }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .overlay(Group { if inputStore.text == "" {
                    Text("Input text" + "...")
                        .foregroundColor(.uiColor(.systemFill))
                }})
            
            if let voteInfo = inputStore.voteInformation, !editing {
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
                                        showVoteAlert = true
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
                
            }
            HStack(spacing: body10) {
                Menu(content: {
                    Button("None", action: { withAnimation { inputStore.selectedTag = nil }})
                    
                    ForEach(inputStore.availableTags, id: \.self) { tag in
                        Button(tag, action: { withAnimation { inputStore.selectedTag = tag }})
                    }
                }, label: {
                    let labelText = inputStore.selectedTag != nil ?
                        "#" + inputStore.selectedTag! : "Select a tag"
                    Text(labelText)
                        .font(.system(size: body14, weight: .semibold))
                        .foregroundColor(.white)
                        .defaultButtonStyle()
                })
                Spacer()
                
                imageButton
                    .matchedGeometryEffect(id: "select.photo", in: animation)
                    .layoutPriority(1)
                
                voteButton
                    .layoutPriority(1)

            }
            .layoutPriority(0.9)
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(12)
        
        // For testing
        .padding()
        .modifier(KeyboardDismissBarModifier(keyboardPresented: $editing))
        .background(Color.background.ignoresSafeArea())
        .navigationBarItems(trailing: Button("Post"/* TODO: localization */, action: { /* TODO: implement actions */ }))
        .modifier(ImagePickerModifier(presented: $showImagePicker, image: $inputStore.image))
        .alert(isPresented: $showVoteAlert) {
            Alert(
                title: Text("The number of the options must be no less than 2"),
                message: Text("Do you want to remove all the options?"),
                primaryButton: .cancel(),
                secondaryButton: .default(Text("Yes"), action: { withAnimation { inputStore.voteInformation = nil }})
            )
        }
    }
}

extension HollowInputView {
    var imageButton: some View {
        ZStack {
            Color.background.aspectRatio(1, contentMode: .fit)
            
            Button(action: { withAnimation {
                if hasImage {
                    inputStore.image = nil
                } else {
                    showImagePicker = true
                    editing = false
                }
            }}) {
                if hasImage { ZStack {
                    if editing {
                        Image(uiImage: inputStore.image!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 2)
                            .matchedGeometryEffect(id: "photo", in: animation)
                    } else {
                        Image(systemName: "photo")
                            .blur(radius: 2)
                            .foregroundColor(Color.hollowContentText.opacity(0.6))
                    }
                    Image(systemName: "xmark")
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
                if editing {
                    editing = false
                    return
                }
                if hasVote { inputStore.voteInformation?.options.append("") }
                else { inputStore.newVote() }
            }}) {
                if hasVote {
                    if editing {
                        Image(systemName: "arrowshape.turn.up.backward.fill")
                    } else {
                        Image(systemName: "plus")
                            .opacity(inputStore.voteInformation!.options.count == 4 ? 0.3 : 1)
                    }
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

extension HollowInputView {
    private struct VoteInputView: View {
        @Binding var voteInfo: HollowInputStore.VoteInformation

        var body: some View {
            VStack {
                ForEach(voteInfo.options.indices, id: \.self) { index in
                    MyTextField(text: $voteInfo.options[index], placeHolder: "Option \(index + 1)") {
                        Button(action: { voteInfo.options.remove(at: index) }) {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                }
            }
        }
    }
}

fileprivate extension View {
    func circularButton(width: CGFloat) -> some View {
        return self
            .frame(width: width, height: width)
            .clipShape(Circle())
    }
}

#if DEBUG
struct HollowInputView_Previews: PreviewProvider {
    static var previews: some View {
        HollowInputView()
//            .background(Color.hollowCardBackground)
//            .cornerRadius(12)
//            .padding()
//            .background(Color.background)
//            .colorScheme(.dark)
    }
}
#endif
