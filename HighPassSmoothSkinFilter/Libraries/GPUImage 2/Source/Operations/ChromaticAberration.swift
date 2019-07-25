//
//  ChromaticAberration.swift
//  Malibu
//
//  Created by Taras Chernyshenko on 5/16/19.
//  Copyright © 2019 Salon Software. All rights reserved.
//

public class ChromaticAberration : BasicOperation {
    public init() {
        super.init(fragmentShader: ChromaticAberration_GL_FragmentShader, numberOfInputs: 1)
    }
}
