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
	float time = CC_Time[2];
	vec4 col = texture2D(u_texture, v_texCoord);
	if(pow(col.a, 3.0) > 0.01)
	{
		vec3 pus = col.rgb * iHighLighPus * abs(sin(1.5*time));
		col.rgb += pus;
		gl_FragColor = vec4(col.r, col.g, col.b, col.a);
	}
	else
	{
		gl_FragColor = col;
	}
}