//
//  CustomScrollView.swift
//  THU-Hole
//
//  Created by liang2kl on 2021/1/14.
//
//  Reference: https://swiftui-lab.com/a-powerful-combo/
//

import SwiftUI

/// Wrapper for SwiftUI's ScrollView to receive delegate callbacks
struct CustomScrollView<Content>: View where Content: View {
    var offset: Binding<CGFloat?> = .constant(nil)
    var atBottom: Binding<Bool?> = .constant(nil)
    var didScrollToBottom: (() -> Void)? = nil
    var didScroll: (() -> Void)? = nil
    var didEndScroll: (() -> Void)? = nil
    var refresh: ((inout Bool) -> Void)? = nil
    let content: (ScrollViewProxy) -> Content
    
    var body: some View {
        ScrollViewRepresentable(offset: offset, atBottom: atBottom, didScroll: didScroll, didScrollToBottom: didScrollToBottom, didEndScroll: didEndScroll, refresh: refresh, content: ScrollView { ScrollViewReader { proxy in content(proxy) }})
    }
}

fileprivate struct ScrollViewRepresentable<Content>: UIViewControllerRepresentable where Content: View {
    typealias UIViewControllerType = ScrollViewUIHostingController<Content>
    
    @Binding var offset: CGFloat?
    @Binding var atBottom: Bool?
    let didScroll: (() -> Void)?
    var didScrollToBottom: (() -> Void)?
    let didEndScroll: (() -> Void)?
    let refresh: ((inout Bool) -> Void)?
    let content: Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScrollViewRepresentable<Content>>) -> ScrollViewUIHostingController<Content> {
        return ScrollViewUIHostingController(offset: self.$offset, atBottom: self.$atBottom, didScroll: didScroll, didScrollToBottom: didScrollToBottom, didEndScroll: didEndScroll, refresh: refresh, rootView: self.content)
    }
    
    func updateUIViewController(_ uiViewController: ScrollViewUIHostingController<Content>, context: UIViewControllerRepresentableContext<ScrollViewRepresentable<Content>>) {
        // necessary here as we need to update the `rootView` property
        // when SwiftUI updates the view (the property `content`)
        uiViewController.rootView = content
    }
}

fileprivate class ScrollViewUIHostingController<Content>: UIHostingController<Content>, UIScrollViewDelegate where Content: View {
    var offset: Binding<CGFloat?>
    var atBottom: Binding<Bool?>
    let didScroll: (() -> Void)?
    var didScrollToBottom: (() -> Void)?
    let didEndScroll: (() -> Void)?
    let refresh: ((inout Bool) -> Void)?
    private var isRefreshing: Bool = false {
        // FIXME: Fix this when actually use it
        didSet { if !isRefreshing {
            DispatchQueue.main.async {
                self.scrollView?.refreshControl?.endRefreshing()
            }
        } }
    }
    var ready = false
    var scrollView: UIScrollView? = nil
    private var isScrolling: Bool = false {
        didSet {
            if isScrolling { didScroll?() }
            else { didEndScroll?() }
        }
    }
    
    init(offset: Binding<CGFloat?>, atBottom: Binding<Bool?>, didScroll: (() -> Void)?, didScrollToBottom: (() -> Void)?, didEndScroll: (() -> Void)?, refresh: ((inout Bool) -> Void)?, rootView: Content) {
        self.offset = offset
        self.atBottom = atBottom
        self.didScroll = didScroll
        self.didScrollToBottom = didScrollToBottom
        self.didEndScroll = didEndScroll
        self.refresh = refresh
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setScrollView()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setScrollView()
    }
    
    private func setScrollView() {
        if ready { return } // avoid running more than once
        ready = true
        
        self.scrollView = findUIScrollView(view: self.view)
        scrollView?.delegate = self
        scrollView?.scrollsToTop = true
        if refresh != nil {
            scrollView?.refreshControl = UIRefreshControl()
            scrollView?.refreshControl?.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
            scrollView?.refreshControl?.isEnabled = true
            scrollView?.refreshControl?.isHidden = false
        }
        view.backgroundColor = nil
        for subView in view.subviews {
            subView.backgroundColor = nil
        }
    }
    
    func findUIScrollView(view: UIView?) -> UIScrollView? {
        if view?.isKind(of: UIScrollView.self) ?? false {
            return (view as? UIScrollView)
        }
        
        for subview in view?.subviews ?? [] {
            if let vc = findUIScrollView(view: subview) {
                return vc
            }
        }
        
        return nil
    }
    
    @objc
    func refreshAction() {
        refresh?(&isRefreshing)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScrolling = true
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            atBottom.wrappedValue = true
            didScrollToBottom?()
        } else {
            atBottom.wrappedValue = false
        }
        offset.wrappedValue = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Solution for detecting slow dragging: if the scroll view is not
        // decelerating, then the end of the dragging marks the end of the scrolling
        if !scrollView.isDecelerating {
            isScrolling = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }
    
}
