//
//  StillImageHighPassFilter.swift
//  Malibu
//
//  Created by Taras Chernyshenko on 7/23/19.
//  Copyright © 2019 Salon Software. All rights reserved.
//

import GPUImage

class StillImageHighPassFilter: OperationGroup {
    private var gaussianBlur: GaussianBlur = GaussianBlur()
    var radiusInPixels: Float = 8.0 {
        didSet {
            self.gaussianBlur.blurRadiusInPixels = self.radiusInPixels
        }
    }
    
    override init() {
        super.init()
        let filter = BasicOperation(fragmentShader: StillImageHighPassFilterFragmentShader, numberOfInputs: 2)
        
        self.configureGroup { (input, output) in
            input --> filter
            input --> self.gaussianBlur --> filter --> output
        }
    }
}

public let StillImageHighPassFilterFragmentShader = """
    varying highp vec2 textureCoordinate;
    varying highp vec2 textureCoordinate2;

    uniform sampler2D inputImageTexture;
    uniform sampler2D inputImageTexture2;

    void main() {
        highp vec4 image = texture2D(inputImageTexture, textureCoordinate);
        highp vec4 blurredImage = texture2D(inputImageTexture2, textureCoordinate2);
        gl_FragColor = vec4((image.rgb - blurredImage.rgb + vec3(0.5,0.5,0.5)), image.a);
    }
"""
