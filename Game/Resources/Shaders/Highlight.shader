shader_type canvas_item;

void fragment()
{
	vec4 tex = texture(TEXTURE, UV);
	tex.rgb -= .3;
	tex.rgb += MODULATE.rgb;
	tex.a *= MODULATE.a;
	COLOR = tex;
}