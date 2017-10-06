uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;


void main() 
{
	//float time = CC_Time[3];
	vec4 col = texture2D(u_texture, v_texCoord);
	if(pow(col.a, 4.0) < 0.01)
	{
		//gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
		return;
	}
	else
	{
		//float base = 0.2 + 0.1 * abs(sin(time));
		//float pus = base + col.r * (1.0 - base);
		//col.r += pus;
		gl_FragColor = vec4(col.r, col.g, col.b, col.a*0.3);	
	}
}
