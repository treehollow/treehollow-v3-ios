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
    
    @ScaledMetric var avatarWidth: CGFloat = 37
    @ScaledMetric var vstackSpacing: CGFloat = 12
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat

    var body: some View {
        VStack(spacing: vstackSpacing) {
            Image("test.avatar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: avatarWidth)
                .clipShape(Circle())
                .leading()
            TextEditor(text: $inputStore.text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .modifier(CustomTextEditorModifier(text: $inputStore.text, editing: $editing))
                .background(Color.clear)
                .overlay(Group { if inputStore.text == "" {
                    Text("Input text" + "...")
                        .foregroundColor(.uiColor(.systemFill))
                }})
            HStack {
                Menu(content: {
                    Button("None", action: { inputStore.selectedTag = nil })

                    ForEach(inputStore.availableTags, id: \.self) { tag in
                        Button(tag, action: { inputStore.selectedTag = tag })
                    }
                }, label: {
                    let labelText = inputStore.selectedTag != nil ?
                        "#" + inputStore.selectedTag! : "Select a tag"
                    Text(labelText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .defaultButtonStyle()
                })
                Spacer()
            }
            .layoutPriority(0.9)
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(12)
        .padding()
        .modifier(KeyboardDismissBarModifier(keyboardPresented: $editing))
        .background(Color.background.ignoresSafeArea())
        .navigationBarItems(trailing: Button("Post"/* TODO: localization */, action: {  }))
    }
}

#if DEBUG
struct HollowInputView_Previews: PreviewProvider {
    static var previews: some View {
        HollowInputView()
            .background(Color.hollowCardBackground)
            .cornerRadius(12)
            .padding()
            .background(Color.background)
            .colorScheme(.dark)
    }
}
#endif
