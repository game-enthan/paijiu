#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
	vec4 color = texture2D(CC_Texture0, v_texCoord).rgba;

	if (0.0 != color.a)
	{
		color.r *= 1.2;
		color.g *= 1.2;
		color.b *= 1.2;
	}

	gl_FragColor = v_fragmentColor * color;
}
