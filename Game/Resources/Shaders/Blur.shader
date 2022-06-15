// simple blur shader. The texture MUST be imported with 'mipmaps' flag !
shader_type canvas_item;

uniform float lod: hint_range(0, 5) = 0.0;

void fragment(){
	vec4 color = texture(TEXTURE, UV, lod);
	COLOR = color;
}