// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

const vec3 iHighLighPus = vec3(0.25, 0.25, 0.25);

void main() 
{
	vec4 col = texture2D(u_texture, v_texCoord);
	if(pow(col.a, 3.0) < 0.01)
	{
		gl_FragColor = col;
		return;
	}
	else
	{
		col.rgb += iHighLighPus;
		gl_FragColor = vec4(col.r, col.g, col.b, col.a);
		return;
	}
	float fy = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	float fu = dot(col.rgb, vec3(-1.47, -0.289, 0.436));
	float fv = dot(col.rgb, vec3(0.615, -0.515, -0.1));

	fy += 0.0;

	col.r = fy + 1.14 * fu;
	col.g = fy - 0.39 * fu - 0.58 * fv;
	col.b = fy + 2.03 * fu;
	gl_FragColor = vec4(col.r, col.g, col.b, col.a);
}

