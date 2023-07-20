shader_type canvas_item;

void fragment() {
	vec4 pcolor = texture(TEXTURE,UV);
	COLOR = vec4(1,1,1,pcolor.a);
}
