#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

//uniform float multiple;

void main()
{
	vec4 color = texture2D(CC_Texture0, v_texCoord).rgba;

	if (0.0 != color.a)
	{
		color.r *= 2.0;
		color.g *= 2.0;
		color.b *= 2.0;
	}

	gl_FragColor = v_fragmentColor * color;
}
