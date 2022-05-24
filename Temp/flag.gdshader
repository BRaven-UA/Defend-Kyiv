// based on original shader created by quizcanners (https://www.shadertoy.com/view/7sBBRV)
shader_type canvas_item;

const float BORDER = 0.1;
uniform sampler2D decal;
uniform vec4 shadow_color: hint_color = vec4(vec3(0.0), 0.65);

void fragment()
{
	vec2 uv = UV;
	vec3 windSeed =  vec3(uv.x * 5.0, uv.y * 7.0, TIME);
	float pole = smoothstep(BORDER, 0.4, uv.x);
	pole = 1.0 - pow(1.0 - pole, 6.0);
	float tension = pow(abs(uv.y - 0.5) * 0.3 ,2.0) * (1.0 - uv.x) * 50.0;
	vec3 gyrPos = vec3(uv.x * (5.0 + uv.y * 5.0 + tension * 15.0) - TIME * 5.0, uv.y * 4.0, TIME * 0.2);
	float windForce = 0.3 + abs(cos(TIME * 0.2 + pole)  * cos(TIME * 0.345));
	float flagUp = 1.0 - windForce;
	uv.x -= pole * flagUp * 0.025; // fabric stretching -> flag length
	float gyr = smoothstep(1.0, 0.0, abs(dot(sin(gyrPos), cos(gyrPos))));
	float wind = sin(TIME * (2.45) -  tension * 3.0 // curve of the vawe
		+ gyr * smoothstep(0.0, 1.0, 1.2 - tension * 2.0)
		- uv.x * (3.0 + tension * 10.0)) * 0.6 *  windForce // Wind phases 
		+ cos(TIME * 0.23 - uv.y * 3.0 + uv.x * 3.0) * 0.5; // perspective waving
	wind *= pole;
	uv += wind * 0.03 * max(0.0, 1.5 - tension);
	float isFlag =
		smoothstep(BORDER, BORDER + dFdx(uv.x) * 2.0, 0.5 - abs(uv.x - 0.5)) *
		smoothstep(BORDER, BORDER + dFdy(uv.y) * 2.0, abs(uv.y - 0.5) - 0.3);
	float shadowThickness = 0.05;
	vec2 shadowUv = (uv - vec2(0.54)) * 1.07;
	float isShadow =
		smoothstep(BORDER - shadowThickness, BORDER, 0.5 - abs(shadowUv.x)) *
		smoothstep(BORDER - shadowThickness, BORDER, 0.5 - abs(shadowUv.y));

//	float isBlue = smoothstep(0.5,0.5 + w*2., uv.y);
//	vec3 col = mix(vec3(0.,0.34,0.71), vec3(1., 0.84, 0.), isBlue);
	
//	float one_third = 1./3.;
//	float red = step(one_third, 2.0*abs(uv.y - 0.5));
//    float green = step(2.0*one_third, uv.y);
//    float blue = step(one_third, uv.y);
//    vec3 col = vec3(red, green, blue);
	
	int i = int(3.0 * (1.1 - uv.y * 1.2));
	vec3 col = vec3(float(i!=1), float(i>1), float(i>0));
	
	vec4 tex = texture(decal, uv / vec2(.4, .4) - vec2(.8));
	col = mix(col, tex.rgb, tex.a);
	col *= (0.95 + wind * 0.3 * pole); // shadow
	col *= 0.8 + tex.rgb; // fabric
	vec4 flag = vec4(col, isFlag);
	COLOR = mix(shadow_color * isShadow, flag, isFlag) ;
}