public class ScreenBlend: BasicOperation {
    public var intensity:Float = 1.0 { didSet { uniformSettings["intensity"] = intensity } }
    public init() {
        super.init(fragmentShader:ScreenBlendFragmentShader, numberOfInputs:2)
        ({intensity = 1.0})()
    }
}
