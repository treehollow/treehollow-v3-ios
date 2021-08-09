//
//  CustomScrollView.swift
//  CustomScrollView
//
//  Created by liang2kl on 2021/8/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Introspect

struct CustomScrollView<Content: View>: View {
    
    @ObservedObject private var scrollViewModel = ScrollViewModel()
    @State private var coordinator: Coordinator?
    
    var didScrollToBottom: (() -> Void)?
    var refresh: ((@escaping () -> Void) -> Void)?
    
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            content()
        }
        .introspectScrollView { scrollView in
            scrollView.delegate = scrollViewModel
            if let refresh = refresh {
                let refreshControl = UIRefreshControl()
                coordinator = Coordinator(refresh: refresh, refreshControl: refreshControl)
                refreshControl.addTarget(coordinator!, action: #selector(coordinator!.refreshAction), for: .valueChanged)
                scrollView.refreshControl = refreshControl
            }
        }
        .onChange(of: scrollViewModel.scrolledToBottom) {
            if $0 { didScrollToBottom?() }
        }
    }
    
    private class Coordinator: NSObject {
        let refreshControl: UIRefreshControl
        var refresh: ((@escaping () -> Void) -> Void)
        
        init(refresh: @escaping (@escaping () -> Void) -> Void, refreshControl: UIRefreshControl) {
            self.refresh = refresh
            self.refreshControl = refreshControl
        }
        @objc func refreshAction() {
            refresh {
                self.refreshControl.endRefreshing()
                self.refreshControl.isHidden = true
            }
        }
    }
}
