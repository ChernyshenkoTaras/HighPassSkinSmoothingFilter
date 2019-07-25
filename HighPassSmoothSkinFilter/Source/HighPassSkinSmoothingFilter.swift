//
//  HighPassSkinSmoothingFilter.swift
//  Malibu
//
//  Created by Taras Chernyshenko on 7/23/19.
//  Copyright © 2019 Salon Software. All rights reserved.
//

import GPUImage
import UIKit

class HighPassSkinSmoothingFilter: OperationGroup {
    private var dissolveFilter: DissolveBlend = DissolveBlend()
    private var sharpenFilter: Sharpen = Sharpen()
    private var skinToneCurveFilter: ToneCurveFilter = ToneCurveFilter()
    private var maskGenerator: HighPassSkinSmoothingMaskGenerator = HighPassSkinSmoothingMaskGenerator()
    private var currentInputSize: CGSize = .zero
    
    var amount: Float = 0.0 {
        didSet {
            self.dissolveFilter.mix = self.amount
            self.sharpenFilter.sharpness = self.sharpnessFactor * self.amount
        }
    }
    
    var controlPoints: [Position] = [] {
        didSet {
            self.skinToneCurveFilter.rgbCompositeControlPoints = self.controlPoints
        }
    }
    
    var sharpnessFactor: Float = 0.0 {
        didSet {
            self.sharpenFilter.sharpness = self.sharpnessFactor * self.amount
        }
    }
    
    var radius: HighPassSkinSmoothingRadius = HighPassSkinSmoothingRadius(fraction: 4.5/750.0) {
        didSet {
            self.maskGenerator.highPassRadiusInPixels = self.radius.value
        }
    }
    
    override init() {
        super.init()
        self.amount = 0.75
        self.sharpnessFactor = 0.4
        self.radius = HighPassSkinSmoothingRadius(fraction: 4.5/750.0)
        
        let controlPoint0 = Position(0, 0)
        let controlPoint1 = Position(120/255.0, 146/255.0)
        let controlPoint2 = Position(1.0, 1.0, 1.0)
        self.controlPoints = [controlPoint0, controlPoint1, controlPoint2]
        
        let composeFilter = BasicOperation(fragmentShader: HighpassSkinSmoothingCompositingFilterFragmentShader, numberOfInputs: 3)
        let exposureFilter = ExposureAdjustment()
        exposureFilter.exposure = -1.0

      
        self.configureGroup { (input, output) in
            self.dissolveFilter.activatePassthroughOnNextFrame = true
            input --> composeFilter
            input --> self.dissolveFilter
            input --> self.skinToneCurveFilter --> self.dissolveFilter --> composeFilter
            input --> exposureFilter --> self.maskGenerator --> composeFilter
         
            composeFilter --> self.sharpenFilter --> output
        }
    }
}

public let HighpassSkinSmoothingCompositingFilterFragmentShader = """
    varying highp vec2 textureCoordinate;
    varying highp vec2 textureCoordinate2;
    varying highp vec2 textureCoordinate3;

    uniform sampler2D inputImageTexture;
    uniform sampler2D inputImageTexture2;
    uniform sampler2D inputImageTexture3;

    void main() {
        highp vec4 image = texture2D(inputImageTexture, textureCoordinate);
        highp vec4 toneCurvedImage = texture2D(inputImageTexture2, textureCoordinate2);
        highp vec4 mask = texture2D(inputImageTexture3, textureCoordinate3);
        gl_FragColor = vec4(mix(image.rgb,toneCurvedImage.rgb, 1.0 - mask.b),1.0);
    }
"""
