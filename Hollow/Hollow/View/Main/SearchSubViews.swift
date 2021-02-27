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
            Image(systemName: "triangle.fill")
                .rotationEffect(Angle(degrees: showsAdvancedOptions ? 180 : 90))
                .font(.system(size: body10))
        }
        .foregroundColor(.plainButton)
        .animation(.none)
        .leading()
        if showsAdvancedOptions {
            AdvancedOptionsView(startPickerPresented: $startPickerPresented, endPickerPresented: $endPickerPresented, startDate: $startDate, endDate: $endDate, selectsPartialSearch: $store.excludeComments)
                .padding()
                .horizontalCenter()
        }
        
        Text("SEARCHVIEW_SEARCH_HISTORY_LABEL")
            .font(.system(size: body16, weight: .semibold))
            .leading()
            .padding(.top)

    }
    
    func topBar() -> some View {
        HStack {
            Button(action:{
                withAnimation {
                    if showPost && store.type == .search {
                        showPost = false
                    } else {
                        presented = false
                    }
                }
            }) {
                Image(systemName: "xmark")
                    .modifier(ImageButtonModifier())
                    .padding(.trailing)
            }
            .animation(.none)
            if showPost && store.type == .search {
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
                
                store.posts.removeAll()
                store.refresh(finshHandler: {})
                
            }, gradient: .vertical(gradient: .button)) {
                Text(store.type == .search ? "SEARCHVIEW_SEARCH_BUTTON" : "SEARCHVIEW_TRENDING_REFRESH_BUTTON")
                    .font(.system(size: buttonFontSize, weight: .bold))
                    .foregroundColor(.white)
            }
            .disabled(store.isLoading)
        }
        .topBar()

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

extension SearchView {
    struct AdvancedOptionsView: View {
        @Binding var startPickerPresented: Bool
        @Binding var endPickerPresented: Bool
        @Binding var startDate: Date
        @Binding var endDate: Date
        @Binding var selectsPartialSearch: Bool
        
        @Environment(\.colorScheme) var colorScheme
        
        @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
        @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
        
        var body: some View {
            VStack {
                Text("SEARCHVIEW_ADVANCED_OPTION_TIME_LEBEL")
                    .fontWeight(.semibold)
                    .leading()
                HStack {
                    timeButton(text: String(startDate.description.prefix(10)), action: {
                        withAnimation {
                            startPickerPresented.toggle()
                        }
                        
                    }).layoutPriority(1)
                    Rectangle().makeDivider(height: 2).foregroundColor(.uiColor(.secondaryLabel)).opacity(0.3).padding(.horizontal)
                    timeButton(text: String(endDate.description.prefix(10)), action: {
                        withAnimation {
                            endPickerPresented.toggle()
                        }
                    }).layoutPriority(1)
                }
                .padding(.bottom)
                .padding(.bottom, 5)
                
                Text("SEARCHVIEW_ADVANCED_OPTION_RANGE_LABEL")
                    .fontWeight(.semibold)
                    .leading()
                    .padding(.bottom, 5)
                rangeButton(text: "SEARCHVIEW_BUTTON_PARTIAL", description: "SEARCHVIEW_BUTTON_PARTIAL_DESCRIPTION", selected: selectsPartialSearch, isPartial: true)
                    .padding(.bottom, 5)
                rangeButton(text: LocalizedStringKey("SEARCHVIEW_BUTTON_GLOBAL"), description: "SEARCHVIEW_BUTTON_GLOBAL_DESCRIPTION", selected: !selectsPartialSearch, isPartial: false)
            }
        }
        
        func timeButton(text: String, action: @escaping () -> Void) -> some View {
            return Button(action: action) {
                Text(text)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .font(.system(size: body14))
                    .foregroundColor(.primary)
                    .background(Color.searchButtonBackground.opacity(colorScheme == .dark ? 0.2 : 0.6))
                    .blurBackground(style: colorScheme == .dark ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark)
                    .cornerRadius(7)
            }
            .animation(.none)
        }
        
        func rangeButton(text: LocalizedStringKey, description: LocalizedStringKey, selected: Bool, isPartial: Bool) -> some View {
            return Button(action: {
                withAnimation {
                    selectsPartialSearch = isPartial
                }
            }) {
                HStack {
                    Text(text)
                        .font(.system(size: body14, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(description)
                        .font(.system(size: body12))
                        .foregroundColor(.secondary)
                }
                .colorScheme(selected ? .dark : colorScheme)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .horizontalCenter()
                .background(
                    Group {
                        if selected {
                            LinearGradient.vertical(gradient: .button)
                        } else {
                            Color.searchButtonBackground.opacity(colorScheme == .dark ? 0.2 : 0.6)
                        }
                    }
                )
                .blurBackground(style: colorScheme == .dark ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark)
                .cornerRadius(10)
            }
            .animation(.none)
        }
    }
}
