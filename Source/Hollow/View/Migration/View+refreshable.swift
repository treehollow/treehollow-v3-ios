//
//  View+refreshable.swift
//  View+refreshable
//
//  Created by liang2kl on 2021/8/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Introspect

extension View {
    @ViewBuilder func refreshable(action: @escaping (@escaping () -> Void) -> Void) -> some View {
        if #available(iOS 15, *) {
            self.refreshable {
                await withCheckedContinuation { continuation in
                    action { continuation.resume() }
                }
            }
        } else {
            self.modifier(Refreshable(action: action))
        }
    }
}

fileprivate struct Refreshable: ViewModifier {
    var action: (@escaping () -> Void) -> Void
    @State private var coordinator: Coordinator?

    func body(content: Content) -> some View {
        content
            .introspectScrollView { scrollView in
                scrollView.contentInsetAdjustmentBehavior = .never
                let refreshControl = UIRefreshControl()
                coordinator = Coordinator(refresh: action, refreshControl: refreshControl)
                refreshControl.addTarget(coordinator!, action: #selector(coordinator!.refreshAction), for: .valueChanged)
                scrollView.refreshControl = refreshControl
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
