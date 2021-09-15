//
//  CustomList.swift
//  Hollow
//
//  Created by liang2kl on 2021/8/2.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Introspect

struct CustomList<Content: View>: View {
    
    @ObservedObject private var scrollViewModel = ScrollViewModel()
    var didScrollToBottom: (() -> Void)?
    var refresh: (@escaping () -> Void) -> Void
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if #available(iOS 15, *), !UIDevice.isPad {
            List {
                content()
                    .defaultListRow()
            }
            .listStyle(.plain)
            
            // Introspect UITableView rather than UIScrollView to
            // avoid unexpectedly discovering TabView's underlying
            // UIScrollView as our scroll view.
            .introspectTableView { tableView in
                (tableView as UIScrollView).delegate = scrollViewModel
                tableView.contentInsetAdjustmentBehavior = .never
            }
            // Refresh control on top.
            .refreshable(action: refresh)

            .onChange(of: scrollViewModel.scrolledToBottom) {
                if $0 { didScrollToBottom?() }
            }
        } else {
            CustomScrollView(
                didScrollToBottom: didScrollToBottom,
                refresh: refresh) {
                    LazyVStack(spacing: 0) {
                        content()
                    }
                }
        }
    }
}
