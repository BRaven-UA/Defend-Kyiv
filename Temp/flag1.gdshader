shader_type canvas_item;


float hash13(vec3 p3)
{
	p3  = fract(p3 * .1031);
	p3 += dot(p3, p3.zyx + 31.32);
	return fract((p3.x + p3.y) * p3.z);
}


void fragment()
{
	vec2 uv = (UV-0.5) *(1.2 - UV.x*0.05) + vec2(0.5, 0.5);
	vec3 windSeed =  vec3(uv.x * 5.,uv.y * 7., TIME);
	float BORDER = 0.1;
	float pole = smoothstep(BORDER, .4, uv.x);
	pole = 1. - pow(1.-pole,6.);
	float tension = pow(abs(uv.y-0.5) * 0.3,2.) * (1. - uv.x) * 50.;
	vec3 gyrPos = vec3(uv.x * (5. + uv.y*5. + tension * 15.) - TIME*5., uv.y*4., TIME * 0.2);
	float windForce = 0.3 + abs(cos(TIME * 0.2 + pole)  * cos(TIME * 0.345));
	float flagUp = 1.-windForce;
	uv.x -= pole * flagUp * 0.025; // fabric stretching -> flag length
	float gyr = smoothstep(1.,0., abs(dot(sin(gyrPos), cos(gyrPos.zxy))));
	vec2 shadowUv = (uv-0.5)*1.3 + vec2(-0.15, 0.15);
	float wind = sin(TIME * (2.45) -  tension * 3. // curve of the vawe
        + gyr * smoothstep(0.,1.,1.2-tension*2.) //* 0.5 
        - uv.x * (3. + tension * 10. )) * 0.6 *  windForce 
        // Wind phases 
       + cos(TIME * 0.23 - uv.y * 3. + uv.x * 3.) * 0.5; // perspective waving
       
	wind *= pole;
	uv += wind*0.03 * max(0., 1.5-tension);
	float w =  length(vec2(dFdx(uv.x), dFdy(uv.y)));
	float isFlag = smoothstep(BORDER,BORDER + dFdx(uv.x)*2., 0.5- abs(uv.x-0.5)) * smoothstep(BORDER,BORDER + dFdy(uv.y) * 2., 0.5- abs(uv.y-0.5));
   
	float shadowThickness = 0.3; // 0.3 * (1. + wind*0.15);
	float shadow = 
   smoothstep(BORDER - shadowThickness, BORDER, 0.5 - abs(shadowUv.x)) 
   * smoothstep(BORDER - shadowThickness, BORDER, 0.5 - abs(shadowUv.y)) ;

	float isBlue = smoothstep(0.5,0.5 + w*2., uv.y);
	vec3 col = mix(vec3(1., 0.84, 0.) , vec3(0.,0.34,0.71), isBlue);
	//vec3(isBlue); // Yelow Blue
	col.rgb *= (0.8 + wind * 0.3 * pole); // shadow
	vec3 tex = texture(TEXTURE, UV).rgb;
	col.rgb *= 0.9 + tex * 0.2; // fabric
	col.rgb += 0.05 * pow(max(0., wind),7. + tex.r * 10.) * vec3(0.3, 0.3, 0.6);  // blick
	float bg = 0.3;
	col.rgb = mix(vec3(bg) * (2. - shadow), col.rgb, isFlag);
	float noise =  hash13(vec3(UV * 15., TIME));
	col.rgb += vec3(noise) * 0.03; // hide color range limit on shadows
	col.rgb += col.gbr*col.brg * 0.3; // Bloom
	COLOR = vec4(col,1.0);
}