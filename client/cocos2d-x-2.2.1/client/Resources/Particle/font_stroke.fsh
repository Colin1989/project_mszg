#ifdef GL_ES
precision highp float;
#endif 
 
uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

//模糊blur的步长，这里只是demo，正式使用由外部传入（uniform类型）
const vec2 step = vec2(0.003, 0.002);

void main(void)
{ 
	//获得当前点的颜色
    vec3 color = texture2D(u_texture, v_texCoord).rgb;
    //该权值用于自身对结果的影响
    float weight = 30.0;
    //加入alpha权重，alpha越大，权值assess越小
    float assess = pow(texture2D(u_texture, v_texCoord).a, 3)*weight;
    //开始计算平均alpha值
    float alpha = assess;
    //以下为高斯模糊（仅对alpha）
    alpha += texture2D( u_texture, v_texCoord.st + vec2( -3.0*step.x, -3.0*step.y ) ).a;
	alpha += texture2D( u_texture, v_texCoord.st + vec2( -2.0*step.x, -2.0*step.y ) ).a;
	alpha += texture2D( u_texture, v_texCoord.st + vec2( -1.0*step.x, -1.0*step.y ) ).a;
	alpha += texture2D( u_texture, v_texCoord.st + vec2( 0.0 , 0.0) ).a;
	alpha += texture2D( u_texture, v_texCoord.st + vec2( 1.0*step.x,  1.0*step.y ) ).a;
	alpha += texture2D( u_texture, v_texCoord.st + vec2( 2.0*step.x,  2.0*step.y ) ).a;
	alpha += texture2D( u_texture, v_texCoord.st + vec2( 3.0*step.x, -3.0*step.y ) ).a;
	alpha /= 7.0+assess;
	//alpha越大，对颜色影响越小
    color = clamp(color + (alpha - 1.0), 0, 1.0);
    //进一步加强颜色的区分
    color = pow(color, vec3(3.0, 3.0, 3.0)); 
    //输出
    gl_FragColor = vec4(color.r, color.g, color.b, alpha) * v_fragmentColor;
} 
