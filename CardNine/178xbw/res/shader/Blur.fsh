#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 resolution;//模糊对象的实际分辨率
uniform float blurRadius;//半径
uniform float sampleStep;// 步长

vec4 blur(vec2);

void main(void)
{
    vec4 col = blur(v_texCoord); //* v_fragmentColor.rgb;
    gl_FragColor = vec4(col) * v_fragmentColor;
}

vec4 blur(vec2 p)
{
    vec4 col = vec4(0);
    vec2 unit = 1.0 / resolution.xy;//单位坐标

    float count = 0.0;
    //遍历一个矩形，当前的坐标为中心点，遍历矩形中每个像素点的颜色
    for(float x = -blurRadius; x < blurRadius; x += sampleStep)
    {
        for(float y = -blurRadius; y < blurRadius; y += sampleStep)
        {
            float weight = (blurRadius - abs(x)) * (blurRadius - abs(y));//权重，p点的权重最高，向四周依次减少
            col += texture2D(CC_Texture0, p + vec2(x * unit.x, y * unit.y)) * weight;
            count += weight;
        }
    }
    //得到实际模糊颜色的值
    return col / count;
}