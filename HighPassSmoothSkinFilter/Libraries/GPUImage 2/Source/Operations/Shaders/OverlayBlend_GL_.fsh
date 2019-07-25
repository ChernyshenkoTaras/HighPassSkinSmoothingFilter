varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

uniform lowp float intensity;

mediump vec4 unpremultiply(mediump vec4 s) {
    return vec4(s.rgb/max(s.a,0.00001), s.a);
}

mediump vec4 premultiply(mediump vec4 s) {
    return vec4(s.rgb * s.a, s.a);
}

mediump float overlaySingleChannel(mediump float b, mediump float s) {
    return b < 0.5 ? (2.0 * s * b) : (1.0 - 2.0 * (1.0 - b) * (1.0 - s));
}

mediump vec4 normalBlend(mediump vec4 Cb, mediump vec4 Cs) {
    mediump vec4 dst = premultiply(Cb);
    mediump vec4 src = premultiply(Cs);
    return unpremultiply(src + dst * (1.0 - src.a));
}

mediump vec4 blendBaseAlpha(mediump vec4 Cb, mediump vec4 Cs, mediump vec4 B) {
    mediump vec4 Cr = vec4((1.0 - Cb.a) * Cs.rgb + Cb.a * clamp(B.rgb, 0.0,  1.0), intensity);
    return normalBlend(Cb, Cr);
}

void main()
{
    mediump vec4 Cb = texture2D(inputImageTexture, textureCoordinate);
    mediump vec4 Cs = texture2D(inputImageTexture2, textureCoordinate2);
    mediump vec4 B = vec4(overlaySingleChannel(Cb.r, Cs.r),overlaySingleChannel(Cb.g, Cs.g),overlaySingleChannel(Cb.b,Cs.b),Cs.a);
    gl_FragColor = blendBaseAlpha(Cb, Cs, B);
}
