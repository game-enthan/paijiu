#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
    vec4 normalColor = texture2D(CC_Texture0, v_texCoord);

	float gray = dot(normalColor.rgb, vec3(0.299, 0.587, 0.114));

    gl_FragColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);

    gl_FragColor.rgb = vec3(gray*gl_FragColor.a, gray*gl_FragColor.a, gray*gl_FragColor.a);
}
