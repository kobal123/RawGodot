shader_type canvas_item;

//uniform isampler2D text;
uniform float zoom: hint_range(0.01, 2.0, 0.01) = 1.0;

void fragment() {

	vec2 scaleCenter = vec2(0.3, 0.2);

	ivec2 cell = ivec2(((UV - scaleCenter) * zoom + scaleCenter) / TEXTURE_PIXEL_SIZE);
	COLOR = texelFetch(TEXTURE,cell,0);

//	COLOR = texture(TEXTURE,UV);
//	COLOR = vec4(1.0);
}
