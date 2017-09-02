#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform float width;
uniform float height;

void main()
{
	vec2 onePixel = vec2(1.0 / width, 1.0 / height);
	vec4 color = vec4(0.5, 0.5, 0.5, 0);
	color -= texture2D(CC_Texture0, v_texCoord - onePixel) * 0.5;
	color += texture2D(CC_Texture0, v_texCoord + onePixel) * 0.5;
	gl_FragColor = vec4(vec3((color.r + color.g + color.b) / 3.0), 1.0); 
}
