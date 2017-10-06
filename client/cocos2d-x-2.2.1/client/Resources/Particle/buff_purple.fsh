#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

vec3 color = vec3(0.55, 0.0, 0.99);
void main() 
{
	float time = CC_Time[3];
	vec4 col = texture2D(u_texture, v_texCoord);
	if(pow(col.a, 3.0) < 0.01)
	{
		gl_FragColor = col;
		return;
	}
	else
	{
		float fact = abs(sin(time)) * 0.2 + 0.8;
		float base = 0.05;
		float pus = base + col.r * (1.0 - base) * color.r * fact;
		col.r += pus;
		pus = base + col.g * (1.0 - base) * color.g * fact;
		col.g += pus;
		pus = base + col.b * (1.0 - base) * color.b * fact;
		col.b += pus;
		gl_FragColor = vec4(col.r, col.g, col.b, col.a);
		return;
	}
}