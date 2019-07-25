// TODO: auto-generate shaders for this, per the Gaussian blur method

public class BilateralBlur: TwoStageOperation {
    public var distanceNormalizationFactor:Float = 8.0 {
        didSet {
            let (_, downsamplingFactor) = sigmaAndDownsamplingForBlurRadius(distanceNormalizationFactor, limit:8.0, override:overrideDownsamplingOptimization)
            sharedImageProcessingContext.runOperationAsynchronously {
                self.downsamplingFactor = downsamplingFactor
                self.shader = crashOnShaderCompileFailure("BilateralBlur") {
                    try sharedImageProcessingContext.programForVertexShader(
                        vertexShaderForBilateralBlur(),
                        fragmentShader:fragmentShaderForBilateralBlur(sigma: Double(self.distanceNormalizationFactor))
                    )
                }
            }
        }
    }
    
    public init() {
        let radius: Float = 8.0
        distanceNormalizationFactor = radius
        let initialShader = crashOnShaderCompileFailure("BilateralBlur") {
            try sharedImageProcessingContext.programForVertexShader(
                vertexShaderForBilateralBlur(),
                fragmentShader:fragmentShaderForBilateralBlur(sigma: Double(radius))
            )
        }
        super.init(shader:initialShader, numberOfInputs:1)
    }
}


func vertexShaderForBilateralBlur() -> String {
    return """
        attribute vec4 position;
        attribute vec4 inputTextureCoordinate;
    
        const int GAUSSIAN_SAMPLES = 9;
    
        uniform float texelWidth;
        uniform float texelHeight;
    
        varying vec2 textureCoordinate;
        varying vec2 blurCoordinates[GAUSSIAN_SAMPLES];
    
        void main()
        {
            gl_Position = position;
            textureCoordinate = inputTextureCoordinate.xy;
    
            // Calculate the positions for the blur
            int multiplier = 0;
            vec2 blurStep;
            vec2 singleStepOffset = vec2(texelWidth, texelHeight);
    
            for (int i = 0; i < GAUSSIAN_SAMPLES; i++)
            {
                multiplier = (i - ((GAUSSIAN_SAMPLES - 1) / 2));
                // Blur in x (horizontal)
                blurStep = float(multiplier) * singleStepOffset;
                blurCoordinates[i] = inputTextureCoordinate.xy + blurStep;
            }
        }
    """
}

func fragmentShaderForBilateralBlur(sigma:Double) -> String {
    let samples = 9
    let multipliers = [0.05, 0.09, 0.12, 0.15, 0.18, 0.15, 0.12, 0.09, 0.05]
    #if GLES
    var shaderString = """
        uniform sampler2D inputImageTexture;
    
        const lowp int GAUSSIAN_SAMPLES = \(samples);
        
        varying highp vec2 textureCoordinate;
        varying highp vec2 blurCoordinates[\(samples)];
        
        
        void main()
        {
            lowp vec4 centralColor;
            lowp float gaussianWeightTotal = 0.0;
            lowp vec4 sum = vec4(0.0, 0.0, 0.0, 0.0);
            lowp vec4 sampleColor;
            lowp float gaussianWeight;
    """
    #else
    var shaderString = """
        uniform sampler2D inputImageTexture;
    
        const int GAUSSIAN_SAMPLES = 9;
        
        varying vec2 textureCoordinate;
        varying vec2 blurCoordinates[GAUSSIAN_SAMPLES];
        
        
        void main()
        {
            vec4 centralColor;
            float gaussianWeightTotal = 0.0;
            vec4 sum = vec4(0.0, 0.0, 0.0, 0.0);
            vec4 sampleColor;
            float gaussianWeight;
    """
    #endif
    shaderString += "centralColor = texture2D(inputImageTexture, blurCoordinates[4]);\n"
    for i in 0..<samples {
        shaderString += """
        sampleColor = texture2D(inputImageTexture, blurCoordinates[\(i)]);
        gaussianWeight = (1.0 - min(distance(centralColor, sampleColor) * \(sigma), 1.0)) * \(multipliers[i]);
        gaussianWeightTotal += gaussianWeight;
        sum += sampleColor * gaussianWeight;
        """
    }
    shaderString += "gl_FragColor = sum / gaussianWeightTotal;}\n"
    return shaderString
}
