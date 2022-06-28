shader_type canvas_item;

const vec2 half = vec2(0.5);
uniform vec2 delta_pos;
uniform sampler2D crater_img;
uniform float crater_strength : hint_range(0.0, 0.1) = 0.011;
uniform float wave_force : hint_range(0.0, 10.0) = 0.005;
uniform vec2 wave_pos1 = vec2(0.5);
uniform vec2 wave_pos2 = vec2(0.5);
uniform vec2 wave_pos3 = vec2(0.5);
uniform vec2 wave_pos4 = vec2(0.5);
uniform vec2 wave_pos5 = vec2(0.5);
uniform vec2 wave_pos6 = vec2(0.5);
uniform vec2 wave_pos7 = vec2(0.5);
uniform vec2 wave_pos8 = vec2(0.5);
uniform vec2 wave_pos9 = vec2(0.5);
uniform float wave_size1 : hint_range(0.0, 1.0) = 0.0;
uniform float wave_size2 : hint_range(0.0, 1.0) = 0.0;
uniform float wave_size3 : hint_range(0.0, 1.0) = 0.0;
uniform float wave_size4 : hint_range(0.0, 1.0) = 0.0;
uniform float wave_size5 : hint_range(0.0, 1.0) = 0.0;
uniform float wave_size6 : hint_range(0.0, 1.0) = 0.0;
uniform float wave_size7 : hint_range(0.0, 1.0) = 0.0;
uniform float wave_size8 : hint_range(0.0, 1.0) = 0.0;
uniform float wave_size9 : hint_range(0.0, 1.0) = 0.0;
uniform vec2 crater_pos1 = vec2(-0.1);
uniform vec2 crater_pos2 = vec2(-0.1);
uniform vec2 crater_pos3 = vec2(-0.1);
uniform vec2 crater_pos4 = vec2(-0.1);
uniform vec2 crater_pos5 = vec2(-0.1);
uniform vec2 crater_pos6 = vec2(-0.1);
uniform vec2 crater_pos7 = vec2(-0.1);
uniform vec2 crater_pos8 = vec2(-0.1);
uniform vec2 crater_pos9 = vec2(-0.1);
uniform vec2 crater_pos10 = vec2(-0.1);
uniform vec2 crater_pos11 = vec2(-0.1);
uniform vec2 crater_pos12 = vec2(-0.1);
uniform vec2 crater_pos13 = vec2(-0.1);
uniform vec2 crater_pos14 = vec2(-0.1);
uniform vec2 crater_pos15 = vec2(-0.1);
uniform vec2 crater_pos16 = vec2(-0.1);

vec2 disp(vec2 center, vec2 uv, float size){
	float len = length(uv - center);
	float mask = 1.0 - smoothstep(size * 0.7, size, len);
	mask *= smoothstep(size * 0.3, size, len) * wave_force * (1.0 - size);
	vec2 disp = normalize(uv - center) * mask;
	return disp;
}

void fragment(){
	vec2 ratio = vec2(1.0, TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y);
	vec2 scaled_uv = UV * ratio;
	vec2 disp1 = disp((wave_pos1 + delta_pos) * ratio, scaled_uv, wave_size1);
	vec2 disp2 = disp((wave_pos2 + delta_pos) * ratio, scaled_uv, wave_size2);
	vec2 disp3 = disp((wave_pos3 + delta_pos) * ratio, scaled_uv, wave_size3);
	vec2 disp4 = disp((wave_pos4 + delta_pos) * ratio, scaled_uv, wave_size4);
	vec2 disp5 = disp((wave_pos5 + delta_pos) * ratio, scaled_uv, wave_size5);
	vec2 disp6 = disp((wave_pos6 + delta_pos) * ratio, scaled_uv, wave_size6);
	vec2 disp7 = disp((wave_pos7 + delta_pos) * ratio, scaled_uv, wave_size7);
	vec2 disp8 = disp((wave_pos8 + delta_pos) * ratio, scaled_uv, wave_size8);
	vec2 disp9 = disp((wave_pos9 + delta_pos) * ratio, scaled_uv, wave_size9);
	vec2 shockwaves = disp1 + disp2 + disp3 + disp4 + disp5 + disp6 + disp7 + disp8 + disp9;
	
	vec2 screen_size = vec2(textureSize(TEXTURE, 0));
	vec2 crater_size = vec2(textureSize(crater_img, 0));
	vec2 crater_scale = screen_size / crater_size;
	vec2 direction = normalize(UV - half); // distortion direction
	vec2 crater_ratio = ratio * crater_scale.x;
	
	vec2 crater_uv1 = (UV - crater_pos1 + delta_pos) * crater_ratio + half;
	vec2 crater_uv2 = (UV - crater_pos2 + delta_pos) * crater_ratio + half;
	vec2 crater_uv3 = (UV - crater_pos3 + delta_pos) * crater_ratio + half;
	vec2 crater_uv4 = (UV - crater_pos4 + delta_pos) * crater_ratio + half;
	vec2 crater_uv5 = (UV - crater_pos5 + delta_pos) * crater_ratio + half;
	vec2 crater_uv6 = (UV - crater_pos6 + delta_pos) * crater_ratio + half;
	vec2 crater_uv7 = (UV - crater_pos7 + delta_pos) * crater_ratio + half;
	vec2 crater_uv8 = (UV - crater_pos8 + delta_pos) * crater_ratio + half;
	vec2 crater_uv9 = (UV - crater_pos9 + delta_pos) * crater_ratio + half;
	vec2 crater_uv10 = (UV - crater_pos10 + delta_pos) * crater_ratio + half;
	vec2 crater_uv11 = (UV - crater_pos11 + delta_pos) * crater_ratio + half;
	vec2 crater_uv12 = (UV - crater_pos12 + delta_pos) * crater_ratio + half;
	vec2 crater_uv13 = (UV - crater_pos13 + delta_pos) * crater_ratio + half;
	vec2 crater_uv14 = (UV - crater_pos14 + delta_pos) * crater_ratio + half;
	vec2 crater_uv15 = (UV - crater_pos15 + delta_pos) * crater_ratio + half;
	vec2 crater_uv16 = (UV - crater_pos16 + delta_pos) * crater_ratio + half;
	vec4 crater1 = texture(crater_img, crater_uv1);
	vec4 crater2 = texture(crater_img, crater_uv2);
	vec4 crater3 = texture(crater_img, crater_uv3);
	vec4 crater4 = texture(crater_img, crater_uv4);
	vec4 crater5 = texture(crater_img, crater_uv5);
	vec4 crater6 = texture(crater_img, crater_uv6);
	vec4 crater7 = texture(crater_img, crater_uv7);
	vec4 crater8 = texture(crater_img, crater_uv8);
	vec4 crater9 = texture(crater_img, crater_uv9);
	vec4 crater10 = texture(crater_img, crater_uv10);
	vec4 crater11 = texture(crater_img, crater_uv11);
	vec4 crater12 = texture(crater_img, crater_uv12);
	vec4 crater13 = texture(crater_img, crater_uv13);
	vec4 crater14 = texture(crater_img, crater_uv14);
	vec4 crater15 = texture(crater_img, crater_uv15);
	vec4 crater16 = texture(crater_img, crater_uv16);
	// distortion distance
	vec2 dist1 = crater1.a * direction;
	vec2 dist2 = crater2.a * direction;
	vec2 dist3 = crater3.a * direction;
	vec2 dist4 = crater4.a * direction;
	vec2 dist5 = crater5.a * direction;
	vec2 dist6 = crater6.a * direction;
	vec2 dist7 = crater7.a * direction;
	vec2 dist8 = crater8.a * direction;
	vec2 dist9 = crater9.a * direction;
	vec2 dist10 = crater10.a * direction;
	vec2 dist11 = crater11.a * direction;
	vec2 dist12 = crater12.a * direction;
	vec2 dist13 = crater13.a * direction;
	vec2 dist14 = crater14.a * direction;
	vec2 dist15 = crater15.a * direction;
	vec2 dist16 = crater16.a * direction;
	
	vec2 crater_dists = dist1 + dist2 + dist3 + dist4 + dist5 + dist6 + dist7 + dist8 + dist9 + dist10 + dist11 + dist12 + dist13 + dist14 + dist15 + dist16;
	vec4 craters = clamp(crater1 + crater2 + crater3 + crater4 + crater5 + crater6 + crater7 + crater8 + crater9 + crater10 + crater11 + crater12 + crater13 + crater14 + crater15 + crater16, 0.0, 0.3);
	vec4 screen = texture(TEXTURE, UV - crater_dists * crater_strength + shockwaves, 0.0);
	COLOR = mix(screen, craters, craters.a); // combine distorted sceen with crater texture
}