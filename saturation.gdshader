shader_type canvas_item;

uniform float rwgt = 0.3086;
uniform float gwgt = 0.6094;
uniform float bwgt = 0.0820;
uniform float saturation:hint_range(0.1,4.0) = -10.0;


//uniform sampler2D text;


void fragment() {
	//vec4 pixelColor = texture(SCREEN_TEXTURE,SCREEN_UV);
	/*
	ivec2 cell = ivec2(UV / TEXTURE_PIXEL_SIZE);
	vec4 pixelColor = texelFetch(TEXTURE,cell,0);
    float  one_m_saturation = 1.0 - saturation;

    mat4 satMat = mat4(vec4(one_m_saturation * rwgt + saturation, one_m_saturation * rwgt, one_m_saturation * rwgt, 0.0)
	, vec4(one_m_saturation * gwgt, one_m_saturation * gwgt + saturation, one_m_saturation * gwgt, 0.0)
	, vec4(one_m_saturation * bwgt, one_m_saturation * bwgt, one_m_saturation * bwgt + saturation, 0.0)
	, vec4(0.0, 0.0, 0.0, 1.0));

	COLOR = satMat * pixelColor;
*/
	ivec2 cell = ivec2(UV / TEXTURE_PIXEL_SIZE);
	vec4 pixelColor = texelFetch(TEXTURE,cell,0);
    float  one_m_saturation = 1.0 - saturation;

    mat4 satMat = mat4(vec4(one_m_saturation * rwgt + saturation, one_m_saturation * rwgt, one_m_saturation * rwgt, 0.0)
	, vec4(one_m_saturation * gwgt, one_m_saturation * gwgt + saturation, one_m_saturation * gwgt, 0.0)
	, vec4(one_m_saturation * bwgt, one_m_saturation * bwgt, one_m_saturation * bwgt + saturation, 0.0)
	, vec4(0.0, 0.0, 0.0, 1.0));

	COLOR = satMat * pixelColor;


}
