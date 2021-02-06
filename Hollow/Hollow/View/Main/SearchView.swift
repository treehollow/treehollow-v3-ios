//
//  SearchView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/17.
//

import SwiftUI
import Defaults

struct SearchView: View {
    @Binding var presented: Bool
    @ObservedObject var viewModel: Search = .init()
    // TODO: Add other options in Defaults
    @State private var showsAdvancedOptions = Defaults[.searchViewShowsAdvanced] {
        didSet { Defaults[.searchViewShowsAdvanced] = showsAdvancedOptions }
    }
    @State private var isSearching = false
    @State private var startPickerPresented = false
    @State private var endPickerPresented = false
    @State var searchText: String = ""
    // TODO: Time constrains
    @State var startDate: Date = .init()
    @State var endDate: Date = .init()
    @State var selectsPartialSearch = false
    private let transitionAnimation = Animation.searchViewTransition
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    @ScaledMetric(wrappedValue: 13, relativeTo: .body) var body13: CGFloat
    @ScaledMetric(wrappedValue: 20, relativeTo: .body) var body20: CGFloat

    var body: some View {
        VStack {
            HStack {
                Button(action:{
                    withAnimation(transitionAnimation) {
                        presented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .imageButton(sizeFor20: body20)
                        .animation(transitionAnimation)
                        .padding(.trailing)
                }
                .animation(.none)
                Spacer()
                MyButton(action: {}, gradient: .vertical(gradient: .button), transitionAnimation: transitionAnimation) {
                    Text(String.searchLocalized.capitalized)
                        .font(.system(size: body13, weight: .bold))
                        .foregroundColor(.white)
                }
                .animation(.none)
            }
            .topBar()
            // Group for additional padding
            Group {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField(LocalizedStringKey("Search content or tags"), text: $searchText, onEditingChanged: { _ in
                            // Toggle `isSearching`
                        }, onCommit: {
                            // Perform search action
                        })
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    .font(.system(size: body16))
                    .padding(.bottom, 5)
                    Rectangle()
                        .frame(height: 1)
                        // TODO: Change color when start editing
                        .foregroundColor(.uiColor(isSearching ? .secondaryLabel : .systemFill))
                }
                .padding(.vertical)
                Button(action:{ withAnimation { showsAdvancedOptions.toggle() }}) {
                    Text(String.advancedLocalized.capitalized)
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
                    AdvancedOptionsView(startPickerPresented: $startPickerPresented, endPickerPresented: $endPickerPresented, startDate: $startDate, endDate: $endDate, selectsPartialSearch: $selectsPartialSearch)
                        .padding()
                        .horizontalCenter()
                        .animation(.searchViewTransition)
                }
                
                Text(String.historyLocalized.capitalized)
                    .font(.system(size: body16, weight: .semibold))
                    .animation(transitionAnimation)
                    .leading()
                    .padding(.top)
                // TODO: Search history
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
        .overlay(
            Group {
                if startPickerPresented {
                    pickerOverlay(isStart: true)
                } else if endPickerPresented {
                    pickerOverlay(isStart: false)
                }
            }
        )
    }
}

extension SearchView {
    private func pickerOverlay(isStart: Bool) -> some View {
        VStack {
            Spacer()
            Text(isStart ? LocalizedStringKey("Choose the start date") : LocalizedStringKey("Choose the end date"))
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
    private struct AdvancedOptionsView: View {
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
                Text(String.timeLocalized.capitalized)
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
                
                Text(String.rangeLocalized.capitalized)
                    .fontWeight(.semibold)
                    .leading()
                    .padding(.bottom, 5)
                rangeButton(text: LocalizedStringKey("Partial"), description: LocalizedStringKey("Hollows only"), selected: selectsPartialSearch, isPartial: true)
                    .padding(.bottom, 5)
                rangeButton(text: LocalizedStringKey("Global"), description: LocalizedStringKey("Hollows and comments"), selected: !selectsPartialSearch, isPartial: false)
            }
        }
        
        private func timeButton(text: String, action: @escaping () -> Void) -> some View {
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
                    .animation(.searchViewTransition)
            }
            .animation(.none)
        }
        
        private func rangeButton(text: LocalizedStringKey, description: LocalizedStringKey, selected: Bool, isPartial: Bool) -> some View {
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
                .animation(.searchViewTransition)
            }
            .animation(.none)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
//            .colorScheme(.dark)
    }
}
