//
//  ScrollViewModel.swift
//  MuseumPlusDemo
//
//  Created by 梁业升 on 2021/6/17.
//  Copyright © 2021 c4explosive. All rights reserved.
//

import SwiftUI

class ScrollViewModel: NSObject, ObservableObject {
    @Published var scrolledToBottom = false
}

extension ScrollViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            if !scrolledToBottom{
                withAnimation { scrolledToBottom = true }
            }

        } else {
            if scrolledToBottom {
                withAnimation { scrolledToBottom = false }
            }
        }
    }
}
