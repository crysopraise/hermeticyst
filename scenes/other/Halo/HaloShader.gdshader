shader_type spatial;
render_mode unshaded, cull_back;

uniform float tiling_scale = 0.02;

const float DEFAULT_SCALE = 0.05;

// enough digits for ya?
const float PI =  3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170680;
const float TAU = 6.2831853071795864769252867665590057683943387987502116419498891846156328125724179972560696506842341360;

// https://gitlab.gnome.org/GNOME/gegl/-/blob/master/operations/common-gpl3+/sinus.c

uniform vec3 base_color_1 = vec3(1, 1, 1);
uniform vec3 background_color = vec3(1, 1, 1);

// These values were generated randomly, should be variable (or manually adjustable)
uniform float c11 : hint_range(-1.0, 1.0);
uniform float c12 : hint_range(-1.0, 1.0);
uniform float c13 : hint_range(0.0, 6.2831853071795864769252867665590057683943387987502116419498891846156328125724179972560696506842341360);

uniform float c21 : hint_range(-1.0, 1.0);
uniform float c22 : hint_range(-1.0, 1.0);
uniform float c23 : hint_range(0.0, 6.2831853071795864769252867665590057683943387987502116419498891846156328125724179972560696506842341360);

uniform float c31 : hint_range(-1.0, 1.0);
uniform float c32 : hint_range(-1.0, 1.0);
uniform float c33 : hint_range(0.0, 6.2831853071795864769252867665590057683943387987502116419498891846156328125724179972560696506842341360);

uniform float complexity : hint_range(0.0, 15.0);
uniform float exponent : hint_range(-7.5, 7.5);

//uniform float transparency_factor : hint_range(0, 1);

float cosinus(float v) {
	return 0.5 - 0.5 * sin ((v + 0.25) * PI * 2.0);
}

void fragment()
{
	float distance = abs(VERTEX.z);
	
	vec2 uv = FRAGCOORD.xy * tiling_scale * sqrt(distance);
	
	float x1 = uv.x + TIME * 2.0;
	float y1 = uv.y + TIME * 2.0;
	
	float c = sin(c31 * x1 + c32 * y1 + c33);
	
	float grey1 = sin(c11 * x1 + c12 * y1 + c13 ) * (0.5 + 0.5 * c) + sin(c21 * x1 + c22 * y1 + c23 ) * (0.5 - 0.5 * c);
	
	grey1 = pow ( cosinus(complexity * (0.5 + 0.5 * grey1)), exponent);
	
	//TODO: Add complexity factor
	//TODO: add some way to adjust the random values
	
	ALBEDO = base_color_1;
	ALPHA = grey1;
}
