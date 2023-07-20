shader_type canvas_item;

uniform float kernel = 3.0;

void fragment() {
    vec2 uv = UV;
    
    uv.x = mod( uv.x * 2.0, 1.0 );
    
    uv = uv * (0.6 + 0.4 * sin(0.5));
    
	ivec2 step_ = ivec2(1,1);
	/*
	
	vec2 step_ = vec2((1.0/1920.0),(1.0/1080.0));
	
	vec3 texA = texture( SCREEN_TEXTURE, SCREEN_UV + vec2(-step_.x, -step_.y) * 1.5 ).rgb;
	vec3 texB = texture( SCREEN_TEXTURE, SCREEN_UV + vec2( step_.x, -step_.y) * 1.5 ).rgb;
	vec3 texC = texture( SCREEN_TEXTURE, SCREEN_UV + vec2(-step_.x,  step_.y) * 1.5 ).rgb;
	vec3 texD = texture( SCREEN_TEXTURE, SCREEN_UV + vec2( step_.x,  step_.y) * 1.5 ).rgb;
   
	*/
	ivec2 cell = ivec2(UV / TEXTURE_PIXEL_SIZE);
	vec3 texA = texelFetch( TEXTURE, cell + ivec2(-step_.x, -step_.y),0 ).rgb;
	vec3 texB = texelFetch( TEXTURE, cell + ivec2( step_.x, -step_.y),0 ).rgb;
	vec3 texC = texelFetch( TEXTURE, cell + ivec2(-step_.x,  step_.y),0 ).rgb;
	vec3 texD = texelFetch( TEXTURE, cell + ivec2( step_.x,  step_.y),0 ).rgb;
   
    vec3 around = 0.25 * (texA + texB + texC + texD);
	vec3 center  = texelFetch( TEXTURE, cell,0 ).rgb;
	
	float sharpness = 50.8;
	
    
	vec3 col = center + (center - around) * kernel;
	
    COLOR = vec4(col,1.0);
}
