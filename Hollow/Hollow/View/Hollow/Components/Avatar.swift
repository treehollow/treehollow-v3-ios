//
//  Avatar.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/14.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct Avatar<HashableValue>: View where HashableValue: Hashable {
    @ObservedObject var store: AvatarStore<HashableValue>
    var resolution: Int { store.configuration.resolution }
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<resolution) { x in
                HStack(spacing: 0) {
                    ForEach(0..<resolution) { y in
                        let index = x * resolution + y
                        Rectangle()
                            .foregroundColor(store.colors[index])
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

class AvatarStore<HashableValue>: ObservableObject where HashableValue: Hashable {
    var configuration: AvatarConfiguration
    @Published var value: HashableValue
    private var generator: AvatarGenerator<HashableValue>
    @Published var colors: [Color]
    
    init(configuration: AvatarConfiguration, value: HashableValue) {
        self.configuration = configuration
        self.value = value
        self.generator = .init(configuration: configuration, value: value)
        self.colors = generator.generateAvatarData()
    }
}

struct Avator_Previews: PreviewProvider {
    static var previews: some View {
        Avatar(store: AvatarStore(configuration: AvatarConfiguration(colors: [.white, .blue], resolution: 6), value: 120934))
    }
}
