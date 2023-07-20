shader_type spatial;

uniform sampler2D baseAlbedo: source_color;
render_mode unshaded;

vec4 toSRGBSlow(vec4 col) {
    bvec4 cutoff = lessThan(col, vec4(0.0031308));
    vec4 higher = vec4(vec3(1.055)*pow(col.rgb, vec3(1.0/2.4)) - vec3(0.055), col.a);
    vec4 lower = vec4(col.rgb * vec3(12.92), col.a);
    return mix(higher, lower, cutoff);
}

vec4 toLinearSlow(vec4 col) {
    bvec4 cutoff = lessThan(col, vec4(0.04045));
    vec4 higher = vec4(pow((col.rgb + vec3(0.055))/vec3(1.055), vec3(2.4)), col.a);
    vec4 lower = vec4(col.rgb/vec3(12.92), col.a);
    return mix(higher, lower, cutoff);
}

void fragment() {
	
	ivec2 cell = ivec2(UV / vec2(1.0/6024.0, 1.0/4024.0));
	vec4 pixelColor = texelFetch(baseAlbedo,cell,0).rgba;
	pixelColor = toLinearSlow(pixelColor);
    //ALBEDO = texture(baseAlbedo, UV).rgb;
	ALBEDO = pixelColor.rgb;
}