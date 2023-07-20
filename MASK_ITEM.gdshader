shader_type canvas_item;

void fragment() {
	
	ivec2 cell = ivec2(UV / TEXTURE_PIXEL_SIZE);
	vec4 pixelColor = texelFetch(TEXTURE,cell,0);
	if(pixelColor.a > 0.0)
		COLOR = vec4(1.0,1.0,1.0,pixelColor.a);
	else
		COLOR = vec4(0.0,0.0,0.0,1.0);		
}
