shader_type canvas_item;

uniform float contrast:hint_range(0.1,4.0) = 1.0;
uniform sampler2D text;
void fragment() {
	ivec2 cell = ivec2(UV / TEXTURE_PIXEL_SIZE);
	vec4 pixelColor = texelFetch(TEXTURE,cell,0);
	vec4 maskPixelColor = texelFetch(text,cell,0);
	//COLOR = maskPixelColor;

	if(maskPixelColor.r < 1.0){
		COLOR = pixelColor;//vec4(1.0,1.0,1.0,1.0);
	}else{
		//COLOR = vec4(1.0,1.0,1.0,1.0);
		COLOR.r = pow(pixelColor.r, contrast);
		COLOR.g = pow(pixelColor.g, contrast);
		COLOR.b = pow(pixelColor.b, contrast);
	}


}
