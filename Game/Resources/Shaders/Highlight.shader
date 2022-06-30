shader_type canvas_item;

void fragment()
{
	vec4 tex = texture(TEXTURE, UV);
	vec4 modulate = MODULATE;
	float enable = step(0.004, modulate.a);
	vec4 highlight = tex;
	highlight.rgb -= .3;
	highlight.rgb += modulate.rgb;
	highlight.a *= modulate.a;
	COLOR = mix(tex, highlight, enable);
//	COLOR = tex;
}