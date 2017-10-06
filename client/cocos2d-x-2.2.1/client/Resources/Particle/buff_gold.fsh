#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

void main() 
{
	float time = CC_Time[2];
	vec4 col = texture2D(u_texture, v_texCoord);
	if(pow(col.a, 3.0) < 0.01)
	{
		gl_FragColor = col;
		return;
	}
	else
	{
		float fact = abs(sin(time));
		float base = 0.05;
		float pus = base + col.r * (1.0 - base) * 0.9 * fact;
		col.r += pus;
		pus = base + col.g * (1.0 - base) * 0.5 * fact;
		col.g += pus;
		gl_FragColor = vec4(col.r, col.g, col.b, col.a);
		return;
	}
}