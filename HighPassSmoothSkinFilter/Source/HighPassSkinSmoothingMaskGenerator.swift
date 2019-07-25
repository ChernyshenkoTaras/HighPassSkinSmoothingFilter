//
//  HighPassSkinSmoothingMaskGenerator.swift
//  Malibu
//
//  Created by Taras Chernyshenko on 7/23/19.
//  Copyright © 2019 Salon Software. All rights reserved.
//

import GPUImage

class HighPassSkinSmoothingMaskGenerator: OperationGroup {
    private var filter: StillImageHighPassFilter = StillImageHighPassFilter()
    
    var highPassRadiusInPixels: Float = 8.0 {
        didSet {
            self.filter.radiusInPixels = self.highPassRadiusInPixels
        }
    }
    
    override init() {
        super.init()
        let channelOverlayFilter = BasicOperation(fragmentShader: GreenAndBlueChannelOverlayFragmentShader, numberOfInputs: 1)
        let maskBoostFilter = BasicOperation(fragmentShader: HighPassSkinSmoothingMaskBoostFilterFragmentShader, numberOfInputs: 1)
        
        self.configureGroup { (input, output) in
            input --> channelOverlayFilter --> self.filter --> maskBoostFilter --> output
        }
    }
}

public let GreenAndBlueChannelOverlayFragmentShader = """
    varying highp vec2 textureCoordinate;
    uniform sampler2D inputImageTexture;

    void main() {
        highp vec4 image = texture2D(inputImageTexture, textureCoordinate);
        highp vec4 base = vec4(image.g,image.g,image.g,1.0);
        highp vec4 overlay = vec4(image.b,image.b,image.b,1.0);
        lowp float ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
        gl_FragColor = vec4(ba,ba,ba,image.a);
    }
"""

public let HighPassSkinSmoothingMaskBoostFilterFragmentShader = """
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

void main() {
    highp vec4 color = texture2D(inputImageTexture,textureCoordinate);

    lowp float hardLightColor = color.b;
    for (int i = 0; i < 3; ++i)
    {
        if (hardLightColor < 0.5) {
            hardLightColor = hardLightColor  * hardLightColor * 2.;
        } else {
            hardLightColor = 1. - (1. - hardLightColor) * (1. - hardLightColor) * 2.;
        }
    }

    lowp float k = 255.0 / (164.0 - 75.0);
    hardLightColor = (hardLightColor - 75.0 / 255.0) * k;

    gl_FragColor = vec4(vec3(hardLightColor),color.a);
}
"""
