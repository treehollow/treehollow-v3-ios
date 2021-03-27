//
//  SplitView.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct SplitView<Primary: View, Secondary: View, ViewModel>: UIViewControllerRepresentable {
    var sharedModel: ViewModel
    var primaryView: (ViewModel) -> Primary
    var secondaryView: (ViewModel) -> Secondary
    var modifiers: ((SplitViewController<Primary, Secondary, ViewModel>) -> Void)?
    
    init(sharedModel: ViewModel, @ViewBuilder primaryView: @escaping (ViewModel) -> Primary, @ViewBuilder secondaryView: @escaping (ViewModel) -> Secondary, modifiers: ((SplitViewController<Primary, Secondary, ViewModel>) -> Void)? = nil) {
        self.primaryView = primaryView
        self.secondaryView = secondaryView
        self.sharedModel = sharedModel
        self.modifiers = modifiers
    }
    
    func makeUIViewController(context: Context) -> SplitViewController<Primary, Secondary, ViewModel> {
        let splitVC = SplitViewController(sharedModel: sharedModel, primaryView: primaryView, secondaryView: secondaryView)
        modifiers?(splitVC)
        return splitVC
    }
    
    func updateUIViewController(_ uiViewController: SplitViewController<Primary, Secondary, ViewModel>, context: Context) {
        uiViewController.primaryController.rootView = primaryView(sharedModel)
        uiViewController.secondaryController.rootView = secondaryView(sharedModel)
    }
}

class SplitViewController<Primary: View, Secondary: View, ViewModel>: UISplitViewController {
    var sharedModel: ViewModel
    var primaryController: UIHostingController<Primary>
    var secondaryController: UIHostingController<Secondary>
    
    init(sharedModel: ViewModel, primaryView: (ViewModel) -> Primary, secondaryView: (ViewModel) -> Secondary) {
        self.sharedModel = sharedModel
        self.primaryController = .init(rootView: primaryView(sharedModel))
        self.secondaryController = .init(rootView: secondaryView(sharedModel))
        super.init(style: .doubleColumn)
        self.setViewController(primaryController, for: .primary)
        self.setViewController(secondaryController, for: .secondary)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
