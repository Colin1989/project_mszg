// Shader taken from: http://webglsamples.googlecode.com/hg/electricflower/electricflower.html

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

const vec3 iHighLighPus = vec3(0.35, 0.35, 0.35);

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
		float duration = mod(time, 20.0);
		if (duration < 15.0)
		{
			gl_FragColor = col;
		}
		else
		{
			vec3 pus = col.rgb * abs(sin(time * 1.5)) * 0.7;
			col.rgb += pus;
			gl_FragColor = vec4(col.r, col.g, col.b, col.a);
		}
		return;
	}
}

