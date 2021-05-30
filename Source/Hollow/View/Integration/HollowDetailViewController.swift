//
//  HollowDetailViewController.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/23.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

class HollowDetailViewController_iPad: UIHostingController<HollowDetailView_iPad> {
    let store: HollowDetailStore

    init(store: HollowDetailStore) {
        self.store = store
        super.init(rootView: HollowDetailView_iPad(store: store))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UITableView.appearance(whenContainedInInstancesOf: [Self.self])
        appearance.backgroundColor = nil
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HollowDetailViewController: UIHostingController<HollowDetailViewWrapper> {
    let store: HollowDetailStore
    let isRoot: Bool
    
    init(store: HollowDetailStore, isRoot: Bool) {
        self.store = store
        self.isRoot = isRoot
        let wrapper = ViewModelWrapper(store: store)
        super.init(rootView: HollowDetailViewWrapper(wrapper: wrapper, isRoot: isRoot))
        wrapper.popHandler = { self.navigationController?.popViewController(animated: true) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        let appearance = UITableView.appearance(whenContainedInInstancesOf: [Self.self])
        appearance.backgroundColor = nil
        if isRoot {
            NotificationCenter.default.post(name: .detailShown, object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isRoot {
            NotificationCenter.default.post(name: .detailDismissed, object: nil)
        }
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct HollowDetailViewWrapper: View {
    fileprivate let wrapper: ViewModelWrapper
    let isRoot: Bool
    @State var presented = true
    
    var body: some View {
        if isRoot {
            HollowDetailView(store: wrapper.store)
                .overlay(Color.black.opacity(0.0001).frame(width: 14).leading())
                .swipeToDismiss(
                    presented: .init(
                        get: { true },
                        set: { if !$0 { dismissSelf(); withAnimation { presented = false }} }
                    )
                )
        } else {
            HollowDetailView(store: wrapper.store)
                // Provide handler to pop back
                .environment(\.popHandler, wrapper.popHandler)
        }
    }
    
}

fileprivate class ViewModelWrapper {
    let store: HollowDetailStore
    var popHandler: (() -> Void)?
    
    init(store: HollowDetailStore) {
        self.store = store
    }
}


fileprivate struct PopBackHandler: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var popHandler: (() -> Void)? {
        get { self[PopBackHandler.self] }
        set { self[PopBackHandler.self] = newValue }
    }
}

extension Notification.Name {
    static let detailShown = Notification.Name("detail.shown")
    static let detailDismissed = Notification.Name("detail.dismissed")
}
