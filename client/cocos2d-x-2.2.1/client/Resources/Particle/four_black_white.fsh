uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;


void main() 
{
	//float time = CC_Time[3];
	vec4 col = texture2D(u_texture, v_texCoord);
	if(pow(col.a, 3.0) < 0.01)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	}
	else
	{
		gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);	
	}
}
