#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

void main()
{
    vec4 c = texture2D(CC_Texture0, v_texCoord);

	//gl_FragColor = vec4(c.rgb * (smoothstep(0.0, 1.0, sin(CC_Time.x * 110.0)) + 1.0), c.a);
    //gl_FragColor = vec4(c.rgb * (mod(CC_Time.x * 40.0, 1.0) + 1.0), c.a);
    gl_FragColor = vec4(c.rgb * (sin(CC_Time.x * 80.0) / 3.0 + 1.0), c.a);
}
