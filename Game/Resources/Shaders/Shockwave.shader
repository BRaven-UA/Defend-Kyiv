//https://www.shadertoy.com/view/Xsl3DH
shader_type canvas_item;

const float PI = 3.1416;
uniform float force = 2.0;
uniform float progression : hint_range(0, 3);
varying vec2 world_pos;

void vertex() {
	world_pos = WORLD_MATRIX[3].xy;
}

vec2 getPixelShift(vec2 center, vec2 pixelpos, float startradius, float size, float shockfactor){
	float m_distance = distance(center, pixelpos);
	if(m_distance > startradius && m_distance < startradius + size){
		float sin_dist = sin((m_distance - startradius) / size * PI) * shockfactor;
		return (pixelpos - normalize(pixelpos - center) * sin_dist);}
	else 
		return pixelpos;}

void fragment(){
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 screen_pos = vec2(world_pos.x, screen_size.y - world_pos.y);
	float startradius = progression * 10.0;
	float size = progression * 300.0;
	float shockfactor = exp(-progression * 1.5) * force;

	vec2 total_shift = getPixelShift(screen_pos, FRAGCOORD.xy, startradius, size, shockfactor);
	COLOR = textureLod(SCREEN_TEXTURE, total_shift * SCREEN_PIXEL_SIZE, 0.0);}