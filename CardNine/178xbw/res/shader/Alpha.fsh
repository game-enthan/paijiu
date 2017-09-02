#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;                                

void main()                                          
{                                                    
	float ratio=0.0;                                    
	vec4 texColor = texture2D(CC_Texture0, v_texCoord);
	if (texColor[3] > 0.05)
	{
		texColor[3] = 0.5f;
	}
	gl_FragColor = texColor;  
}
