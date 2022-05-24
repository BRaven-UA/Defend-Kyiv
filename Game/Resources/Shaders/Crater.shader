shader_type canvas_item;

uniform float str = -0.011;

void fragment()
{
	vec4 decal = texture(TEXTURE, UV);
	vec2 direction = normalize(UV - vec2(0.5)); // distortion direction
	vec2 dist = decal.a * direction; // distortion distance
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV + dist * str);
	
	COLOR = mix(decal, screen, decal.a * 0.75); // combine distorted sceen with decal texture
}