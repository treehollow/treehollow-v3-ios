//
//  HollowTextView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowTextView: View {
    @Binding var text: String
    var compactLineLimit: Int? = nil
    var body: some View {
        Text(text)
            .hollowContent()
            .leading()
            .foregroundColor(.hollowContentText)
            .lineLimit(compactLineLimit)
    }
}

struct HollowTextView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            HollowTextView(text: .constant(
                """
*italics* or _italics_
**bold** or __bold__
~~Linethrough~~Strikethroughs.
`code`

# Header 1
> quote
>> quoteor

Header 1
====

## Header 2

or

Header 2
---

### Header 3
#### Header 4
##### Header 5 #####
###### Header 6 ######

    Indented code blocks (spaces or tabs)

[Links](http://voyagetravelapps.com/)
![Images](<Name of asset in bundle>)

[Referenced Links][1]
![Referenced Images][2]

[1]: http://voyagetravelapps.com/
[2]: <Name of asset in bundle>

> Blockquotes

- Bulleted
- Lists
    - Including indented lists
        - Up to three levels
- Neat!

1. Ordered
1. Lists
    1. Including indented lists
        - Up to three levels
"""
            ),
            compactLineLimit: nil)
        }
    }
}
