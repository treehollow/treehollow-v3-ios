//
//  SearchView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct SearchView: View {
    @Binding var presented: Bool
    @State private var searchText: String = ""
    @State private var showsAdvancedOptions = true // FIXME
    @State private var isSearching = false
    private let transitionAnimation = Animation.searchViewTransition
    var body: some View {
        VStack {
            HStack {
                Button(action:{
                    withAnimation(transitionAnimation) {
                        presented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.plainButton)
                        .animation(transitionAnimation)
                }
                .animation(.none)
                Spacer()
                MyButton(action: {}, gradient: .vertical(gradient: .button), transitionAnimation: transitionAnimation) {
                    Text(LocalizedStringKey("Search"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .animation(.none)
            }
            // Group for additional padding
            Group {
                VStack(spacing: 0) {
                    TextField(LocalizedStringKey("Search"), text: $searchText, onEditingChanged: { _ in
                        // Toggle `isSearching`
                    }, onCommit: {
                        // Perform search action
                    })
                        .font(.system(size: 16))
                        .padding(.bottom, 5)
                    Rectangle()
                        .frame(height: 1)
                        // TODO: Change color when start editing
                        .foregroundColor(.uiColor(isSearching ? .secondaryLabel : .systemFill))
                }
                .padding(.vertical)
                    Button(action:{ showsAdvancedOptions.toggle() }) {
                        Text(LocalizedStringKey("Advanced"))
                            .font(.system(size: 16, weight: .medium))
                            .animation(transitionAnimation)
                        Image(systemName: "triangle.fill")
                            .rotationEffect(Angle(degrees: showsAdvancedOptions ? 180 : 90))
                            .animation(transitionAnimation)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.plainButton)
                    .animation(.none)
                    .leading()
                if showsAdvancedOptions {
                    AdvancedOptionsView()
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding(.horizontal)
        // Background color
        .background(Color.background.opacity(0.4).edgesIgnoringSafeArea(.all))
        // Blur background
        .blurBackground(style: .systemUltraThinMaterial)
        .transition(.move(edge: .bottom))
        .animation(transitionAnimation)
    }
}

extension SearchView {
    private struct AdvancedOptionsView: View {
        var body: some View {
            VStack {
                Text(LocalizedStringKey("Time"))
                HStack {
                    timeButton(text: "Start", action: {})
                }
            }
        }
        
        private func timeButton(text: String, action: @escaping () -> Void) -> some View {
            return Button(action: action) {
                Text(text)
                    .foregroundColor(.primary)
                    .background(Color.searchButtonBackground.opacity(0.3))
                    .animation(.searchViewTransition)
            }
            .animation(.none)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .colorScheme(.dark)
    }
}
