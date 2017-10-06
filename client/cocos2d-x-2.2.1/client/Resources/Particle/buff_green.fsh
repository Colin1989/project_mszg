#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

vec3 colorTransform(vec3 multiplier, vec3 offset, vec3 col)
{
	vec3 newCol = vec3(0.0);
	newCol.r = multiplier.r * col.r + offset.r;
	newCol.g = multiplier.r * col.g + offset.g;
	newCol.b = multiplier.r * col.b + offset.b;
	return newCol;
}


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
		float base = 0.2 + 0.1 * abs(sin(time));
		float pus = base + col.b * (1.0 - base);
		col.g += pus;
		gl_FragColor = vec4(col.r, col.g, col.b, col.a);
		return;
	}
}