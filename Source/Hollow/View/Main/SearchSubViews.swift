//
//  SearchSubViews.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

extension SearchView {
    @ViewBuilder func searchConfigurationView() -> some View {

        AdvancedOptionsView(startPickerPresented: $startPickerPresented, endPickerPresented: $endPickerPresented, startDate: $store.startDate, endDate: $store.endDate, selectsPartialSearch: $store.excludeComments)
            .padding([.vertical, .horizontal, .bottom])
            .padding(.bottom)
            .horizontalCenter()
        
        HistoryView(searchText: $store.searchString)
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
            } else {
                Spacer()
            }
            MyButton(action: {
                withAnimation {
                    hideKeyboard()
                    showPost = true
                }
                updateHistoryDefaults(with: store.searchString)
                store.posts.removeAll()
                store.refresh(finshHandler: {})
                
            }, gradient: .vertical(gradient: .button)) {
                Text(store.type == .search ? "SEARCHVIEW_SEARCH_BUTTON" : "SEARCHVIEW_TRENDING_REFRESH_BUTTON")
                    .font(.system(size: buttonFontSize, weight: .bold))
                    .foregroundColor(.white)
            }
            .disabled(store.isLoading || store.searchString == "")
        }
        .topBar()

    }
    
    func searchField() -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("SEARCHVIEW_TEXTFIELD_PLACEHOLDER", text: $store.searchString, onEditingChanged: { _ in
                    // Toggle `isSearching`
//                    showPost = false
                }, onCommit: {
                    // Perform search action
                })
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
            .matchedGeometryEffect(id: "searchview.searchbar", in: animation)
            .font(.system(size: body16))
            .padding(.bottom, showPost ? 0 : 5)
            if !showPost {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.uiColor(store.searchString != "" ? .systemGray2 : .systemFill))
                    .animation(.default)
            }
        }
    }
    
    func updateHistoryDefaults(with newHistory: String) {
        var exist = false
        for history in searchHistory {
            if history == newHistory {
                exist = true
                let index = searchHistory.firstIndex(of: history)!
                searchHistory.remove(at: index)
                searchHistory.insert(newHistory, at: 0)
                break
            }
        }
        if !exist { searchHistory.insert(newHistory, at: 0) }
    }
}

extension SearchView {
    func bindingDate(isStart: Bool) -> Binding<Date> {
        if isStart {
            return Binding(
                get: { store.startDate ?? Date() },
                set: { store.startDate = $0 }
            )
        } else {
            return Binding(
                get: { store.endDate ?? Date() },
                set: { store.endDate = $0 }
            )
        }
    }
    func pickerOverlay(isStart: Bool) -> some View {
        var dateRange: ClosedRange<Date> {
            if isStart { return Date.distantPast...(store.endDate ?? Date.distantFuture) }
            else { return (store.startDate ?? Date.distantPast)...Date.distantFuture }
        }
        
        return VStack {
            Spacer()
            Text(isStart ? "SEARCHVIEW_PICKER_START" : "SEARCHVIEW_PICKER_END")
                .bold()
                .padding(.bottom)
            DatePicker("", selection: bindingDate(isStart: isStart), in: dateRange, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .horizontalCenter()
                .labelsHidden()
            
            MyButton(action: { withAnimation {
                if isStart {
                    store.startDate = nil
                    startPickerPresented = false
                } else {
                    store.endDate = nil
                    endPickerPresented = false
                }
            }}) {
                Text("SEARCHVIEW_PICKER_CLEAR_BUTTON")
                    .modifier(MyButtonDefaultStyle())
            }
            .padding(.top)

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
        @Binding var startDate: Date?
        @Binding var endDate: Date?
        @Binding var selectsPartialSearch: Bool
        
        @Environment(\.colorScheme) var colorScheme
        
        @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
        @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
        
        private var startButtonText: String {
            if let startDate = startDate {
                return String(startDate.description.prefix(10))
            }
            return NSLocalizedString("SEARCHVIEW_SELECT_START_DATE_BUTTON", comment: "")
        }
        
        private var endButtonText: String {
            if let endDate = endDate {
                return String(endDate.description.prefix(10))
            }
            return NSLocalizedString("SEARCHVIEW_SELECT_END_DATE_BUTTON", comment: "")
        }

        
        var body: some View {
            VStack {
                Text("SEARCHVIEW_ADVANCED_OPTION_TIME_LEBEL")
                    .fontWeight(.semibold)
                    .leading()
                HStack {
                    timeButton(text: startButtonText, hasContent: startDate != nil, action: {
                        withAnimation {
                            startDate = startDate ?? Date()
                            startPickerPresented.toggle()
                        }
                        
                    }).layoutPriority(1)
                    Rectangle().makeDivider(height: 2).foregroundColor(.uiColor(.secondaryLabel)).opacity(0.3).padding(.horizontal)

                    timeButton(text: endButtonText, hasContent: endDate != nil, action: {
                        withAnimation {
                            endDate = endDate ?? Date()
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
        
        func timeButton(text: String, hasContent: Bool, action: @escaping () -> Void) -> some View {
            return Button(action: action) {
                Text(text)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .font(.system(size: body14, weight: hasContent ? .semibold : .medium))
                    .foregroundColor(hasContent ? .white : .primary)
                    .background(Group { if hasContent {
                        LinearGradient.vertical(gradient: .button)
                    } else {
                        Color.searchButtonBackground.opacity(colorScheme == .dark ? 0.2 : 0.6)
                    }})
                    .blurBackground(style: colorScheme == .dark ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark)
                    .cornerRadius(7)
            }
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
        }
    }
}

extension SearchView {
    struct HistoryView: View {
        @Default(.searchHistory) var searchHistory
        @Binding var searchText: String
        @ScaledMetric(wrappedValue: 17, relativeTo: .body) var body17: CGFloat
        @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
        @ScaledMetric(wrappedValue: 15) var historySpcing: CGFloat
        var body: some View {
            HStack {
                Text("SEARCHVIEW_SEARCH_HISTORY_LABEL")
                Spacer()
                Button(action: { withAnimation {
                    searchHistory.removeAll()
                }}) {
                    Image(systemName: "trash")
                        .foregroundColor(.uiColor(.systemFill))
                }
            }
            .font(.system(size: body17, weight: .semibold))
            .padding(.top)
            
            ScrollView(showsIndicators: false) { VStack(spacing: historySpcing) {
                ForEach(searchHistory, id: \.self) { history in
                    Text(history)
                        .foregroundColor(.secondary)
                        .leading()
                        .font(.system(size: body16))
                        .onTapGesture {
                            withAnimation { searchText = history }
                            guard let index = searchHistory.firstIndex(of: history) else { return }
                            withAnimation {
                                searchHistory.remove(at: index)
                                searchHistory.insert(history, at: 0)
                            }
                        }
                }
            }}
            .padding(.top, 10)
        }
    }
}
