//
//  CustomTabView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Foundation

/// A workaround to set the background color of `CustomScrollView` inside `TabView` to `nil`
struct CustomTabView<Content, HashableValue>: View where Content: View, HashableValue: Hashable {
    var selection: Binding<HashableValue>
    let content: () -> Content
    var ignoreSafeAreaEdges: Edge.Set
    
    init(selection: Binding<HashableValue>, ignoreSafeAreaEdges: Edge.Set = .init(), @ViewBuilder content: @escaping () -> Content) {
        self.selection = selection
        self.content = content
        self.ignoreSafeAreaEdges = ignoreSafeAreaEdges
    }
    
    var body: some View {
        TabViewRepresentable(content:
                                TabView(selection: selection) { content() }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                .edgesIgnoringSafeArea(ignoreSafeAreaEdges))
    }
}

fileprivate struct TabViewRepresentable<Content>: UIViewControllerRepresentable where Content: View {
    typealias UIViewControllerType = TabViewUIHostingController<Content>
    
    let content: Content
    @Environment(\.disableScrolling) var disableScroll
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TabViewRepresentable<Content>>) -> TabViewUIHostingController<Content> {
        return TabViewUIHostingController(disableScroll: disableScroll, rootView: self.content)
    }
    
    func updateUIViewController(_ uiViewController: TabViewUIHostingController<Content>, context: UIViewControllerRepresentableContext<TabViewRepresentable<Content>>) {
        // necessary here as we need to update the `rootView` property
        // when SwiftUI updates the view (the property `content`)
        uiViewController.topScrollView?.isScrollEnabled = !disableScroll
        uiViewController.rootView = content
    }
}

fileprivate class TabViewUIHostingController<Content>: UIHostingController<Content> where Content: View {
    var ready = false
    var disableScroll: Bool
    var topScrollView: UIScrollView?
    
    init(disableScroll: Bool, rootView: Content) {
        self.disableScroll = disableScroll
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if ready { return } // avoid running more than once
        ready = true
        view.backgroundColor = nil
        setHostingScrollViews(for: view)
    }
    
    private func setHostingScrollViews(for view: UIView) {
        let HostingScrollView: AnyClass? = NSClassFromString("SwiftUI.HostingScrollView")
        for subView in view.subviews {
            if subView.isKind(of: UIScrollView.self) {
                
                // Disable `scrollsToTop` on other scrollView
                if let HostingScrollView = HostingScrollView,
                   !subView.isKind(of: HostingScrollView) {
                    (subView as! UIScrollView).scrollsToTop = false
                    topScrollView = topScrollView ?? subView as? UIScrollView
                }
                
                // Set the background of the wrapper view to nil
                view.backgroundColor = nil
            }
            setHostingScrollViews(for: subView)
        }
    }
    
}
