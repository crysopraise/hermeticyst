shader_type spatial;
render_mode unshaded;

uniform float tiling_scale = 0.1;

const float DEFAULT_SCALE = 0.05;

// enough digits for ya?
const float PI =  3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170680;
const float TAU = 6.2831853071795864769252867665590057683943387987502116419498891846156328125724179972560696506842341360;

// https://gitlab.gnome.org/GNOME/gegl/-/blob/master/operations/common-gpl3+/sinus.c

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

float cosinus(float v) {
	return 0.5 - 0.5 * sin ((v + 0.25) * PI * 2.0);
}

void fragment()
{
	vec2 uv = FRAGCOORD.xy * tiling_scale;
	
	float x = uv.x + TIME * 2.0;
	float y = uv.y + TIME * 2.0;
	
	float c = sin(c31 * x + c32 * y + c33);
	
	float grey = sin(c11 * x + c12 * y + c13 ) * (0.5 + 0.5 * c) + sin(c21 * x + c22 * y + c23 ) * (0.5 - 0.5 * c);
	
	grey = pow ( cosinus(complexity * (0.5 + 0.5 * grey)), exponent);
	
	//TODO: Add complexity factor
	//TODO: add some way to adjust the random values
	
	ALBEDO = vec3(1.0, 1.0, 1.0);
	ALPHA = grey;
}
