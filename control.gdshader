shader_type canvas_item;

uniform float killswitch = 1.0;
uniform vec4 color = vec4(1.0,0.0,0.0,0.0);

void fragment() {
	ivec2 cell = ivec2(UV / TEXTURE_PIXEL_SIZE);
	vec4 pixelColor = texelFetch(TEXTURE,cell,0);
	if(pixelColor.a < 1.0)
		COLOR = color * killswitch;
//		COLOR = vec4(0.0, 0.5, 0.0, 0.5);
//		COLOR = vec4(0.0);
	else
		COLOR = vec4(0.0);		
	
}
