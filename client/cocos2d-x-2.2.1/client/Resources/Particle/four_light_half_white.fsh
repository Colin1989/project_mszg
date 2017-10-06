uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;


void main() 
{
	//float time = CC_Time[3];
	vec4 col = texture2D(u_texture, v_texCoord);
	if(pow(col.a,3.0) < 0.01)
	{
		gl_FragColor = vec4(0.618, 0.618,0.618, col.a*0.2);
	}
	else
	{
		gl_FragColor = vec4(col.r, col.g, col.b, col.a*0.3);	
	}
}
