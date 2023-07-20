shader_type canvas_item;


uniform float brightness;
uniform float contrast;
uniform float saturation;
		
uniform float rwgt = 0.3086;
uniform float gwgt = 0.6094;
uniform float bwgt = 0.0820;
uniform float kernel;
void fragment() {
	vec4 pixelColor = texture(TEXTURE,UV);
	
	
	
    vec2 uv = UV;
    
    uv.x = mod( uv.x * 2.0, 1.0 );
    
    uv = uv * (0.6 + 0.4 * sin(0.5));
    
	vec2 step = vec2((1.0/1920.0),(1.0/1080.0));
	
	vec3 texA = texture( TEXTURE, UV + vec2(-step.x, -step.y) * 1.5 ).rgb;
	vec3 texB = texture( TEXTURE, UV + vec2( step.x, -step.y) * 1.5 ).rgb;
	vec3 texC = texture( TEXTURE, UV + vec2(-step.x,  step.y) * 1.5 ).rgb;
	vec3 texD = texture( TEXTURE, UV + vec2( step.x,  step.y) * 1.5 ).rgb;
   
    vec3 around = 0.25 * (texA + texB + texC + texD);
	vec3 center  = texture( TEXTURE, UV ).rgb;
	
	float sharpness = 1.8;
	
    
	vec3 col = center + (center - around) * kernel;
	
    COLOR = vec4(col,1.0);


	COLOR = vec4(COLOR.r * brightness,COLOR.g * brightness, COLOR.b * brightness,pixelColor.a);
	COLOR.r = pow(COLOR.r,contrast);
	COLOR.g = pow(COLOR.g,contrast);
	COLOR.b = pow(COLOR.b,contrast);

    float  one_m_saturation = 1.0 - saturation;

    mat4  satMat = mat4(vec4(one_m_saturation * rwgt + saturation, one_m_saturation * rwgt, one_m_saturation * rwgt, 0.0)
	, vec4(one_m_saturation * gwgt, one_m_saturation * gwgt + saturation, one_m_saturation * gwgt, 0.0)
	, vec4(one_m_saturation * bwgt, one_m_saturation * bwgt, one_m_saturation * bwgt + saturation, 0.0)
	, vec4(0.0, 0.0, 0.0, 1.0));

	COLOR = satMat * COLOR;


}