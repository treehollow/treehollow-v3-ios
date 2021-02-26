//
//  SearchSubViews2.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

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
                    .animation(.searchViewTransition)
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
                .animation(.searchViewTransition)
            }
            .animation(.none)
        }
    }
}
