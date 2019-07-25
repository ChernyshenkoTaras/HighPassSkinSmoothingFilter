//
//  HighPassSkinSmoothingRadius.swift
//  Malibu
//
//  Created by Taras Chernyshenko on 7/23/19.
//  Copyright © 2019 Salon Software. All rights reserved.
//

import Foundation

enum HighPassSkinSmoothingRadiusUnit {
    case pixel
    case fractionOfImageWidth
}

class HighPassSkinSmoothingRadius {
    var unit: HighPassSkinSmoothingRadiusUnit
    var value: Float
    
    init(pixels: Float) {
        self.value = pixels
        self.unit = .pixel
    }
    
    init(fraction: Float) {
        self.value = fraction
        self.unit = .fractionOfImageWidth
    }
}
