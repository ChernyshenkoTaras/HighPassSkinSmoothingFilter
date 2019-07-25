varying vec2 textureCoordinate;
varying vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

uniform lowp float intensity;

void main()
{
    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
    vec4 whiteColor = vec4(1.0);
    
    vec4 result = whiteColor - ((whiteColor - vec4(intensity * textureColor2.r, intensity * textureColor2.g, intensity * textureColor2.b, intensity)) * (whiteColor - textureColor));
    gl_FragColor = vec4(result.r, result.g, result.b, 1.0);
}
