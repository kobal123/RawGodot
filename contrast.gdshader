shader_type canvas_item;

uniform float contrast:hint_range(0.1,4.0) = 3.0;
//uniform sampler2D text;
void fragment() {
	/*vec4 pixelColor = texture(SCREEN_TEXTURE,SCREEN_UV);
	
	vec4 maskColor = texture(text,SCREEN_UV);
	float val = (maskColor.a + 1.0)/2.0;
		COLOR.r = pow(pixelColor.r, contrast * val);
		COLOR.g = pow(pixelColor.g, contrast * val );
		COLOR.b = pow(pixelColor.b, contrast  * val);
*/
	ivec2 cell = ivec2(UV / TEXTURE_PIXEL_SIZE);
	vec4 pixelColor = texelFetch(TEXTURE,cell,0);
	COLOR.r = pow(pixelColor.r, contrast);
	COLOR.g = pow(pixelColor.g, contrast);
	COLOR.b = pow(pixelColor.b, contrast);
	//COLOR += 40.0;
}
