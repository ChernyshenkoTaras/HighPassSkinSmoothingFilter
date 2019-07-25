public class OverlayBlend: BasicOperation {
    public var intensity:Float = 1.0 { didSet { uniformSettings["intensity"] = intensity } }
    public init() {
        super.init(fragmentShader:OverlayBlend_GL_FragmentShader, numberOfInputs:2)
        
        ({intensity = 1.0})()
    }
}
