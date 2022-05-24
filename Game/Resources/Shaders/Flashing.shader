shader_type canvas_item;

uniform vec4 modulate : hint_color;
uniform float intensity : hint_range(0.0, 50.0) = 6.0;

void fragment(){
	vec4 tex = textureLod(TEXTURE, UV, 0);
	tex *= modulate;
	tex.a *= sin(TIME * intensity) / 2.0 + 1.0;
	COLOR = tex;
}