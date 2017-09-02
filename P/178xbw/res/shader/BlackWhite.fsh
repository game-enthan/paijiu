#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform float u_threshold;

void main()
{
    vec4 normalColor = texture2D(CC_Texture0, v_texCoord);
	float gray = dot(normalColor.rgb, vec3(0.299, 0.587, 0.114));
	if(gray > u_threshold)
	{
		gl_FragColor = vec4(1.0); 
	}
	else
	{
		gl_FragColor = vec4(0.0); 
	}
}
