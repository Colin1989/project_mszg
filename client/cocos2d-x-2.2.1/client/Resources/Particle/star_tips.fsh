#ifdef GL_ES
precision mediump float;
#endif


vec2 resolution = vec2(80.0, 80.0);

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;

void main() 
{
	float iGlobalTime = CC_Time[2];
	vec4 col = texture2D(u_texture, v_texCoord);
	if(pow(col.a, 3.0) < 0.01)
	{
		gl_FragColor = col;
		return;
	}
	else
	{
		vec2 uv = gl_FragCoord.xy / resolution.yy;
		float fc = 0.0;
		fc += iGlobalTime * 1.9; 
		float distance = 1.0 - abs(-uv.x - uv.y + fc) / sqrt(2.0);
		distance = smoothstep(0.0, 1.0, distance);
		//distance = pow(distance, 3.2);
		//distance += 0.5;
		col.rgb += distance;
		gl_FragColor = col;
	}
}