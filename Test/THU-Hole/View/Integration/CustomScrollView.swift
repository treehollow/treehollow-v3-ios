//
//  CustomScrollView.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/14.
//
//  Reference: https://swiftui-lab.com/a-powerful-combo/
//

import SwiftUI

struct CustomScrollView<Content>: View where Content: View {
    let atBottom: Binding<Bool>
    let didScroll: () -> Void
    let didEndScroll: () -> Void
    let content: () -> Content
    
    init(atBottom: Binding<Bool>, didScroll: @escaping () -> Void = { }, didEndScroll: @escaping () -> Void = { }, content: @escaping () -> Content) {
        self.atBottom = atBottom
        self.didScroll = didScroll
        self.didEndScroll = didEndScroll
        self.content = content
    }
    
    var body: some View {
        ScrollViewRepresentable(atBottom: atBottom, didScroll: didScroll, didEndScroll: didEndScroll, content: ScrollView { content() })
    }
}

fileprivate struct ScrollViewRepresentable<Content>: UIViewControllerRepresentable where Content: View {
    typealias UIViewControllerType = ScrollViewUIHostingController<Content>
    
    @Binding var atBottom: Bool
    let didScroll: () -> Void
    let didEndScroll: () -> Void
    let content: Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScrollViewRepresentable<Content>>) -> ScrollViewUIHostingController<Content> {
        return ScrollViewUIHostingController(atBottom: self.$atBottom, didScroll: didScroll, didEndScroll: didEndScroll, rootView: self.content)
    }
    
    func updateUIViewController(_ uiViewController: ScrollViewUIHostingController<Content>, context: UIViewControllerRepresentableContext<ScrollViewRepresentable<Content>>) {
        // necessary here as we need to update the `rootView` property
        // when SwiftUI updates the view (the property `content`)
        uiViewController.rootView = content
    }
}

fileprivate class ScrollViewUIHostingController<Content>: UIHostingController<Content>, UIScrollViewDelegate where Content : View {
    var atBottom: Binding<Bool>
    let didScroll: () -> Void
    let didEndScroll: () -> Void
    var ready = false
    var scrollView: UIScrollView? = nil
    private var isScrolling: Bool = false {
        didSet {
            if isScrolling { didScroll() }
            else { didEndScroll() }
        }
    }
    private var didBeginDecelerating = false
    
    init(atBottom: Binding<Bool>, didScroll: @escaping () -> Void, didEndScroll: @escaping () -> Void, rootView: Content) {
        self.atBottom = atBottom
        self.didScroll = didScroll
        self.didEndScroll = didEndScroll
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if ready { return } // avoid running more than once
        ready = true
        
        self.scrollView = findUIScrollView(view: self.view)
        scrollView?.delegate = self

        super.viewDidAppear(animated)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScrolling = true
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            atBottom.wrappedValue = true
        } else {
            atBottom.wrappedValue = false
        }
    }
    
    // FIXME: Fail to invoke didEndScroll when scrolling slowly

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }
}
