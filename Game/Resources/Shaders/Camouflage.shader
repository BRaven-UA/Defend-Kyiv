shader_type canvas_item;

uniform sampler2D noise_image;
uniform vec4 color1 : hint_color = vec4(0.3, 0.5, 0.2, 1.0);
uniform vec4 color2 : hint_color = vec4(0.8, 0.8, 0.1, 1.0);
uniform float scale : hint_range(0.0, 10.0) = 1.0;
uniform float smoothness : hint_range(0.0, 50.0) = 17.0;

void fragment(){
	vec4 font = texture(TEXTURE, UV);
	vec4 camouflage = texture(noise_image, UV * scale);
	float value = smoothstep(0.0, 1.0, (length(camouflage.rgb) - 0.8) * smoothness);
	camouflage = mix(color1, color2, value);
	COLOR.a = font.a;
	COLOR.rgb *= camouflage.rgb;
}