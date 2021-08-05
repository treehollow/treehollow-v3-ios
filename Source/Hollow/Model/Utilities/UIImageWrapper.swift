//
//  UIImageWrapper.swift
//  Hollow
//
//  Created by liang2kl on 2021/8/6.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

class UIImageWrapper: Codable {
    var image: UIImage
    
    enum CodingKeys: CodingKey {
        case data
    }
    
    init(image: UIImage) {
        self.image = image
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        try container.encode(data, forKey: .data)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let data = try values.decode(Data.self, forKey: .data)
        guard let image = UIImage(data: data) else {
            throw DecodeError.error
        }
        self.image = image
    }
    
    enum DecodeError: Error {
        case error
    }
}
