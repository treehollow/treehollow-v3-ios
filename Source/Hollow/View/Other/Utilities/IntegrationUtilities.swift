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

struct IntegrationUtilities {
    static var topSplitVC: UISplitViewController?
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
    
    static func getSplitViewController() -> UISplitViewController? {
        return topSplitVC
    }
    
    static private func getSplitViewController(of parent: UIViewController) -> UISplitViewController? {
        for child in parent.children {
            print(child)
            if let child = child as? UISplitViewController { return child }
            if let vc = getSplitViewController(of: child) { return vc }
        }
        return nil
    }
    
    static func keyWindow() -> UIWindow? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    }
    
    static func presentView<Content: View>(presentationStyle: UIModalPresentationStyle = .formSheet, transitionStyle: UIModalTransitionStyle = .coverVertical, @ViewBuilder content: () -> Content) {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = nil
        vc.modalPresentationStyle = presentationStyle
        vc.modalTransitionStyle = transitionStyle
        guard let topVC = IntegrationUtilities.topViewController() else { return }
        topVC.present(vc, animated: true)
    }
    
    static func setCustomColorScheme(_ colorScheme: CustomColorScheme = Defaults[.colorScheme]) {
        keyWindow()?.overrideUserInterfaceStyle =
            colorScheme == .system ? .unspecified :
            colorScheme == .light ? .light : .dark
    }
    
    static func presentSafariVC(url: URL) {
        let safari = SFSafariViewController(url: url)
        topViewController()?.present(safari, animated: true)
    }
    
    static func getSecondaryNavigationVC() -> UINavigationController? {
        if let topVC = getSplitViewController(),
           let navVC = topVC.viewController(for: .secondary)?.parent as? UINavigationController {
            return navVC
        }
        return nil
    }
    
    static func pushView<Content: View>(navigationVC: UINavigationController, @ViewBuilder content: () -> Content) {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = nil
        navigationVC.pushViewController(vc, animated: true)
    }
    
    static func pushViewOnSecondary<Content: View>(@ViewBuilder content: () -> Content) {
        guard let navVC = getSecondaryNavigationVC() else { return }
        pushView(navigationVC: navVC, content: content)
    }
    
    static func conditionallyPresentView<Content: View>(@ViewBuilder content: () -> Content) {
        if UIDevice.isPad {
            pushViewOnSecondary(content: content)
        } else {
            presentView(content: content)
        }
    }
}
