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
    var didScrollToBottom: (() -> Void)? = nil
    var refresh: ((@escaping () -> Void) -> Void)? = nil
    let content: () -> Content
    
    var body: some View {
        ScrollViewRepresentable(didScrollToBottom: didScrollToBottom, refresh: refresh, content: ScrollView { content() })
    }
}

enum ScrollDirection { case up, down }

fileprivate struct ScrollViewRepresentable<Content>: UIViewControllerRepresentable where Content: View {
    typealias UIViewControllerType = ScrollViewUIHostingController<Content>
    
    var didScrollToBottom: (() -> Void)?
    let refresh: ((@escaping () -> Void) -> Void)?
    let content: Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScrollViewRepresentable<Content>>) -> ScrollViewUIHostingController<Content> {
        return ScrollViewUIHostingController(didScrollToBottom: didScrollToBottom, refresh: refresh, rootView: self.content)
    }
    
    func updateUIViewController(_ uiViewController: ScrollViewUIHostingController<Content>, context: UIViewControllerRepresentableContext<ScrollViewRepresentable<Content>>) {
        uiViewController.rootView = content
    }
}

fileprivate class ScrollViewUIHostingController<Content>: UIHostingController<Content>, UIScrollViewDelegate where Content: View {
    
    var didScrollToBottom: (() -> Void)?
    let refresh: ((@escaping () -> Void) -> Void)?
    var ready = false
    var scrollView: UIScrollView? = nil
    
    init(didScrollToBottom: (() -> Void)?, refresh: ((@escaping () -> Void) -> Void)?, rootView: Content) {
        self.didScrollToBottom = didScrollToBottom
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
        if ready && scrollView != nil { return } // avoid running more than once
        ready = true
        
        self.scrollView = findUIScrollView(view: self.view)
        scrollView?.delegate = self
        scrollView?.keyboardDismissMode = .onDrag

        #if !targetEnvironment(macCatalyst)
        if refresh != nil {
            scrollView?.refreshControl = UIRefreshControl()
            scrollView?.refreshControl?.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
            scrollView?.refreshControl?.isEnabled = true
            scrollView?.refreshControl?.isHidden = false
        }
        #endif
        view.backgroundColor = nil
        for subView in view.subviews {
            subView.backgroundColor = nil
        }
    }
    
    func findUIScrollView(view: UIView) -> UIScrollView? {
        if view.isKind(of: UIScrollView.self) {
            return (view as? UIScrollView)
        }
        
        for subview in view.subviews {
            if let sv = findUIScrollView(view: subview) {
                return sv
            }
        }
        
        return nil
    }
    
    @objc
    func refreshAction() {
        refresh? {
            DispatchQueue.main.async {
                self.scrollView?.refreshControl?.endRefreshing()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            didScrollToBottom?()
        }
    }
}
