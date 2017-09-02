varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

uniform vec3 u_outlineColor;
uniform float u_threshold;
uniform float u_radius;

void main()
{
    float radius = u_radius;
    vec4 accum = vec4(0.0);
    vec4 normal = vec4(0.0);
    
    vec4 c = texture2D(CC_Texture0, vec2(v_texCoord.x, v_texCoord.y));
    
    accum += texture2D(CC_Texture0, vec2(v_texCoord.x - radius, v_texCoord.y - radius));
    accum += texture2D(CC_Texture0, vec2(v_texCoord.x + radius, v_texCoord.y - radius));
    accum += texture2D(CC_Texture0, vec2(v_texCoord.x + radius, v_texCoord.y + radius));
    accum += texture2D(CC_Texture0, vec2(v_texCoord.x - radius, v_texCoord.y + radius));
    
    accum *= u_threshold;
    accum.rgb =  u_outlineColor * accum.a;
    accum.a = 1.0;
    
    normal = ( accum * (1.0 - c.a)) + (c * c.a);
    if(normal.x > 0.5 || normal.y > 0.5 || normal.z > 0.5)
    {
    	gl_FragColor = v_fragmentColor * normal;
	}
	else
	{
		gl_FragColor = c;
	}
}

