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

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HollowDetailViewController: UIHostingController<HollowDetailView> {
    let store: HollowDetailStore
    
    init(store: HollowDetailStore) {
        self.store = store
        super.init(rootView: HollowDetailView(store: store))
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
