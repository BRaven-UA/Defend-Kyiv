shader_type canvas_item;

uniform float force : hint_range(0.0, 10.0) = 0.02;
uniform vec2 pos1 = vec2(0.5);
uniform vec2 pos2 = vec2(0.5);
uniform vec2 pos3 = vec2(0.5);
uniform vec2 pos4 = vec2(0.5);
uniform vec2 pos5 = vec2(0.5);
uniform vec2 pos6 = vec2(0.5);
uniform vec2 pos7 = vec2(0.5);
uniform vec2 pos8 = vec2(0.5);
uniform vec2 pos9 = vec2(0.5);
uniform float size1 : hint_range(0.0, 1.0) = 0.0;
uniform float size2 : hint_range(0.0, 1.0) = 0.0;
uniform float size3 : hint_range(0.0, 1.0) = 0.0;
uniform float size4 : hint_range(0.0, 1.0) = 0.0;
uniform float size5 : hint_range(0.0, 1.0) = 0.0;
uniform float size6 : hint_range(0.0, 1.0) = 0.0;
uniform float size7 : hint_range(0.0, 1.0) = 0.0;
uniform float size8 : hint_range(0.0, 1.0) = 0.0;
uniform float size9 : hint_range(0.0, 1.0) = 0.0;


vec2 disp(vec2 center, vec2 uv, float size){
	float len = length(uv - center);
	float mask = 1.0 - smoothstep(size * 0.7, size, len);
	mask *= smoothstep(size * 0.3, size, len) * force * (1.0 - size);
	vec2 disp = normalize(uv - center) * mask;
	return disp;
}

void fragment(){
	vec2 ratio = vec2(1.0, TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y);
	vec2 scaled_uv = UV * ratio;
	vec2 disp1 = disp(pos1 * ratio, scaled_uv, size1);
	vec2 disp2 = disp(pos2 * ratio, scaled_uv, size2);
	vec2 disp3 = disp(pos3 * ratio, scaled_uv, size3);
	vec2 disp4 = disp(pos4 * ratio, scaled_uv, size4);
	vec2 disp5 = disp(pos5 * ratio, scaled_uv, size5);
	vec2 disp6 = disp(pos6 * ratio, scaled_uv, size6);
	vec2 disp7 = disp(pos7 * ratio, scaled_uv, size7);
	vec2 disp8 = disp(pos8 * ratio, scaled_uv, size8);
	vec2 disp9 = disp(pos9 * ratio, scaled_uv, size9);
	COLOR = texture(TEXTURE, UV - disp1 - disp2 - disp3 - disp4 - disp5 - disp6 - disp7 - disp8 - disp9);
}