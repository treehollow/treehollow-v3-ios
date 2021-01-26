//
//  CustomTabView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Foundation

/// An ugly but **working** workaround to set the background color of `CustomScrollView` in `TabView` to `nil`
struct CustomTabView<Content, HashableValue>: View where Content: View, HashableValue: Hashable {
    var selection: Binding<HashableValue>
    let content: () -> Content
    
    init(selection: Binding<HashableValue>, @ViewBuilder content: @escaping () -> Content) {
        self.selection = selection
        self.content = content
    }
    
    var body: some View {
        TabViewRepresentable(content: TabView(selection: selection) { content() }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)))
    }
}

fileprivate struct TabViewRepresentable<Content>: UIViewControllerRepresentable where Content: View {
    typealias UIViewControllerType = TabViewUIHostingController<Content>
    
    let content: Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TabViewRepresentable<Content>>) -> TabViewUIHostingController<Content> {
        return TabViewUIHostingController(rootView: self.content)
    }
    
    func updateUIViewController(_ uiViewController: TabViewUIHostingController<Content>, context: UIViewControllerRepresentableContext<TabViewRepresentable<Content>>) {
        // necessary here as we need to update the `rootView` property
        // when SwiftUI updates the view (the property `content`)
        uiViewController.rootView = content
    }
}

fileprivate class TabViewUIHostingController<Content>: UIHostingController<Content> where Content: View {
    var ready = false
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if ready { return } // avoid running more than once
        ready = true
        for vc in self.children {
            print(vc.self)
            if vc is UIPageViewController {
                fatalError()
            }
        }
        view.backgroundColor = nil
        setHostingScrollViews(for: view)
        super.viewDidAppear(animated)
    }
    
    private func setHostingScrollViews(for view: UIView) {
        // FIXME: WARNING: This code could fail after system update!
        let HostingScrollView: AnyClass = NSClassFromString("SwiftUI.HostingScrollView")!
        for subView in view.subviews {
            if subView.isKind(of: HostingScrollView) {
                print(view, "\n")
                view.backgroundColor = nil
            }
            setHostingScrollViews(for: subView)
        }
    }
}
