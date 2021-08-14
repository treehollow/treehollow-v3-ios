//
//  IntegrationUtilities.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults
import SafariServices

/// A set of imperative methods for using UIKit in SwiftUI.
struct IntegrationUtilities {
    // MARK: - Presentation
    
    static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
                .map { $0 as? UIWindowScene }
                .compactMap {$0}
                .first?.windows
                .filter { $0.isKeyWindow }.first
    }
    
    /// Get the top view controller. Necessary when presenting a new view controller.
    static func topViewController() -> UIViewController? {
        let keyWindow = IntegrationUtilities.keyWindow()

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    /// Present SwiftUI View modally.
    static func presentView<Content: View>(presentationStyle: UIModalPresentationStyle = .formSheet, transitionStyle: UIModalTransitionStyle = .coverVertical, modalInPresentation: Bool = false, @ViewBuilder content: () -> Content) {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = nil
        vc.modalPresentationStyle = presentationStyle
        vc.modalTransitionStyle = transitionStyle
        vc.isModalInPresentation = modalInPresentation
        guard let topVC = IntegrationUtilities.topViewController() else { return }
        topVC.present(vc, animated: true)
    }

    /// Present `SFSafariViewController` with specific URL.
    static func presentSafariVC(url: URL) {
        let safari = SFSafariViewController(url: url)
        topViewController()?.present(safari, animated: true)
    }
    
    // MARK: - SplitViewController on iPad
    
    /// Reference of the main split vc on iPad. Set when the vc is being set up.
    static var topSplitVC: UISplitViewController?

    /// Get the secondary vc of the split vc.
    static func getSecondaryNavigationVC() -> UINavigationController? {
        if let topVC = topSplitVC,
           let navVC = topVC.viewController(for: .secondary)?.parent as? UINavigationController {
            return navVC
        }
        return nil
    }
    
    /// Push the given view to the secondary side of the split vc.
    static func pushViewOnSecondary<Content: View>(@ViewBuilder content: () -> Content) {
        guard let navVC = getSecondaryNavigationVC() else { return }
        pushView(navigationVC: navVC, content: content)
    }

    // MARK: - Presenting Detail View
    
    /// Refresh the current detail view or present a new detail view based on the context.
    static func openTemplateDetailView(postId: Int, jumpToComment commentId: Int? = nil) {
        var store: HollowDetailStore? = nil
        if UIDevice.isPad {
            if let navVC = getSecondaryNavigationVC(),
               let detailVC = navVC.topViewController as? HollowDetailViewController_iPad {
                store = detailVC.store
            }
        } else {
            if let detailVC = getDetailVC() {
                store = detailVC.store
            }
        }
        
        // If the currently presented view controller is `HollowDetailViewController(_iPad)`
        // and its postId is the same as the destination post, then we just refresh it, otherwise
        // we present a new view controller.
        if let store = store, store.postDataWrapper.post.postId == postId {
            store.jumpToCommentId = commentId
            store.requestDetail()
        } else {
            let templateWrapper = PostDataWrapper.templatePost(for: postId)
            IntegrationUtilities.conditionallyPresentDetail(store: .init(bindingPostWrapper: .constant(templateWrapper), jumpToComment: commentId))
        }
    }
    
    /// On iPad, push the view on the secondary side of the split vc, otherwise present it modally.
    static func conditionallyPresentDetail(store: HollowDetailStore) {
        if UIDevice.isPad {
            pushDetailVCOnSecondary(store: store)
        } else {
            presentDetailView(store: store)
        }
    }
    
    static func presentDetailView(store: HollowDetailStore) {
        if let navVC = topViewController() as? UINavigationController,
           navVC.topViewController is HollowDetailViewController {
            let detailVC = HollowDetailViewController(store: store, isRoot: false)
            detailVC.view.backgroundColor = nil
            navVC.pushViewController(detailVC, animated: true)
        } else {
            let detailVC = HollowDetailViewController(store: store, isRoot: true)
            detailVC.view.backgroundColor = nil
            let navVC = UINavigationController(rootViewController: detailVC)
            navVC.modalPresentationStyle = .overFullScreen
            topViewController()?.present(navVC, animated: true)
        }
    }
    
    static func pushDetailVCOnSecondary(store: HollowDetailStore) {
        guard let navVC = getSecondaryNavigationVC() else { return }
        let vc = HollowDetailViewController_iPad(store: store)
        vc.view.backgroundColor = nil
        navVC.pushViewController(vc, animated: true)
    }
    
    static func topDetailVC() -> HollowDetailViewController? {
        return topViewController() as? HollowDetailViewController
    }

    // MARK: - Other
    
    /// Override the color scheme.
    static func setCustomColorScheme(_ colorScheme: CustomColorScheme = Defaults[.colorScheme]) {
        keyWindow()?.overrideUserInterfaceStyle =
            colorScheme == .system ? .unspecified :
            colorScheme == .light ? .light : .dark
    }
    
}

// MARK: - Private helper methods
extension IntegrationUtilities {
    static private func getSplitViewController(of parent: UIViewController) -> UISplitViewController? {
        for child in parent.children {
            if let child = child as? UISplitViewController { return child }
            if let vc = getSplitViewController(of: child) { return vc }
        }
        return nil
    }
    
    static private func pushView<Content: View>(navigationVC: UINavigationController, @ViewBuilder content: () -> Content) {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = nil
        navigationVC.pushViewController(vc, animated: true)
    }
    
    static private func getDetailVC() -> HollowDetailViewController? {
        return (topViewController() as? UINavigationController)?.topViewController as? HollowDetailViewController
    }
}
