/* 
  ChromaticAberration_GL_.fsh
  Malibu

  Created by Taras Chernyshenko on 5/16/19.
  Copyright © 2019 Salon Software. All rights reserved.
*/
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main()
{
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    
    lowp float rOffset = 0.0025;
    lowp float gOffset = 0.002;
    lowp float bOffset = 0.003;
    lowp vec4 rValue = texture2D(inputImageTexture, vec2((textureCoordinate.x + rOffset), (textureCoordinate.y)));
    lowp vec4 gValue = texture2D(inputImageTexture, vec2((textureCoordinate.x + gOffset), (textureCoordinate.y + gOffset)));
    lowp vec4 bValue = texture2D(inputImageTexture, vec2((textureCoordinate.x - bOffset), (textureCoordinate.y)));
    
    // Combine the offset colors.
    gl_FragColor = vec4(rValue.r, gValue.g, bValue.b, textureColor.w);
}
