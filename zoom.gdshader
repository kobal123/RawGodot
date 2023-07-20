shader_type canvas_item;

uniform float zoom = 100.0;//:hint_range(0.1,10);
uniform float scaleCenterx:hint_range(0.1,1.0);
uniform float scaleCentery:hint_range(0.1,1.0);// = vec2(0.68,0.87);
void fragment() {
	vec2 uv = UV;
	vec2 scaleCenter =  vec2(scaleCenterx,scaleCentery);
	uv = uv / zoom;
    
	
	vec4 pixelColor = texture(TEXTURE,uv);
	
	COLOR = pixelColor;
}
