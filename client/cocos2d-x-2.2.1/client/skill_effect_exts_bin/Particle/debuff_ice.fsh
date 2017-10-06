#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

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
		col.b += 0.5;
		gl_FragColor = vec4(col.r, col.g, col.b, col.a);
		return;
	}
}