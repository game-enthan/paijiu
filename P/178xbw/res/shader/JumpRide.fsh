#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform float tick;

void main()
{
	vec4 color = texture2D(CC_Texture0, v_texCoord).rgba;
	
	if (0.0 != color.a)
	{
		color.r *= (tick + 1.0);
		color.g *= (tick + 1.0);
		color.b *= (tick + 1.0);
	}

	gl_FragColor = v_fragmentColor * color;
}