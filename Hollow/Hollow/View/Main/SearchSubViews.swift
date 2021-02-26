//
//  SearchSubViews.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension SearchView {
    @ViewBuilder func searchConfigurationView() -> some View {
        Button(action:{ withAnimation { showsAdvancedOptions.toggle() }}) {
            Text("SEARCHVIEW_ADVANCED_BUTTON")
                .font(.system(size: body16, weight: .semibold))
                .animation(transitionAnimation)
            Image(systemName: "triangle.fill")
                .rotationEffect(Angle(degrees: showsAdvancedOptions ? 180 : 90))
                .animation(transitionAnimation)
                .font(.system(size: body10))
        }
        .foregroundColor(.plainButton)
        .animation(.none)
        .leading()
        if showsAdvancedOptions {
            AdvancedOptionsView(startPickerPresented: $startPickerPresented, endPickerPresented: $endPickerPresented, startDate: $startDate, endDate: $endDate, selectsPartialSearch: $store.excludeComments)
                .padding()
                .horizontalCenter()
                .animation(.searchViewTransition)
        }
        
        Text("SEARCHVIEW_SEARCH_HISTORY_LABEL")
            .font(.system(size: body16, weight: .semibold))
            .animation(transitionAnimation)
            .leading()
            .padding(.top)

    }
    
    func topBar() -> some View {
        HStack {
            Button(action:{
                withAnimation(transitionAnimation) {
                    if showPost {
                        showPost = false
                    } else {
                        presented = false
                    }
                }
            }) {
                Image(systemName: showPost ? "chevron.left" : "xmark")
                    .modifier(ImageButtonModifier())
                    .animation(transitionAnimation)
                    .padding(.trailing)
            }
            .animation(.none)
            if showPost {
                searchField()
                    .matchedGeometryEffect(id: "searchview.searchbar", in: animation)
            } else {
                Spacer()
            }
            MyButton(action: {
                withAnimation {
                    hideKeyboard()
                    showPost = true
                }
                
                store.refresh(finshHandler: {})
                
            }, gradient: .vertical(gradient: .button), transitionAnimation: transitionAnimation) {
                Text("SEARCHVIEW_SEARCH_BUTTON")
                    .font(.system(size: buttonFontSize, weight: .bold))
                    .foregroundColor(.white)
            }
            .animation(.none)
            .topBar()
        }
    }
    
    func searchField() -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("SEARCHVIEW_TEXTFIELD_PLACEHOLDER", text: $store.searchString, onEditingChanged: { _ in
                    // Toggle `isSearching`
//                    showPost = false
                }, onCommit: {
                    // Perform search action
                })
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
            .font(.system(size: body16))
            .padding(.bottom, showPost ? 0 : 5)
            if !showPost {
                Rectangle()
                    .frame(height: 1)
                    // TODO: Change color when start editing
                    .foregroundColor(.uiColor(isSearching ? .secondaryLabel : .systemFill))
            }
        }
    }
}

extension SearchView {
    func pickerOverlay(isStart: Bool) -> some View {
        VStack {
            Spacer()
            Text(isStart ? "SEARCHVIEW_PICKER_START" : "SEARCHVIEW_PICKER_END")
                .bold()
                .padding(.bottom)
            DatePicker("", selection: isStart ? $startDate : $endDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .horizontalCenter()
                .labelsHidden()
        }
        .background(
            Blur(style: .systemUltraThinMaterial)
                .edgesIgnoringSafeArea(.all)
                // Dismiss the view when the user tap outside the picker
                .onTapGesture {
                    withAnimation {
                        if isStart { startPickerPresented = false }
                        else { endPickerPresented = false }
                    }
                }
        )
    }
}


