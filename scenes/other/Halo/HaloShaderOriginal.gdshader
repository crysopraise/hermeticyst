shader_type spatial;
render_mode unshaded;
// Renders a tileable 2D texture to screen, using spatial polygons as a mask.
// Remove blur from textures by unchecking "Detect 3D" and "Filter" in Import.
// Demo: https://github.com/DeerTears/Polygon-Mask-for-2D-Textures/

uniform sampler2D tiling_texture;

uniform float tiling_scale = 1.0;

const float DEFAULT_SCALE = 8.0;

// PI should be a defined constant in the shader language but isn't for some reason
// This is probably close enough for graphics, though
const float pi = 3.1415926535;

//const float x_scroll_factor = 1.0;
//const float y_scroll_factor = 1.0;

void fragment() {
	float x_scroll_factor = (sin(TIME * 0.15)) * 0.05;
	float y_scroll_factor = (cos(TIME * 0.15)) * 0.05;

	vec2 timeoffset = vec2(TIME * x_scroll_factor, TIME * y_scroll_factor) * 10.0;
	vec2 uv = FRAGCOORD.xy + timeoffset;
	vec2 tiling_uv = uv / (DEFAULT_SCALE * tiling_scale * -1.0);
	vec4 texture_result = texture(tiling_texture, tiling_uv);
	ALBEDO = texture_result.rgb * vec3(1.0, 0.4, 0.0);
	ALPHA = texture_result.a;
}