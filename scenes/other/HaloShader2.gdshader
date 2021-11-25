shader_type spatial;

uniform float tiling_scale = 1.0;

const float DEFAULT_SCALE = 0.05;

// https://gitlab.gnome.org/GNOME/gegl/-/blob/master/operations/common-gpl3+/sinus.c

// These values were generated randomly, should be variable (or manually adjustable)
uniform float c11 = 0.4043848108;
uniform float c12 = -0.2337558202;
uniform float c13 = 2.1910072645;

uniform float c21 = 0.205968991;
uniform float c22 = -0.4620033348;
uniform float c23 = 3.8266088364;

uniform float c31 = -0.0389273908;
uniform float c32 = 0.0740396556;
uniform float c33 = 6.2087192989;

void fragment()
{
	vec2 uv = FRAGCOORD.xy * 1.1;
	
	float x = uv.x;
	float y = uv.y;
	
	float c = sin(c31 * x + c32 * y + c33);
	
	float grey = sin(c11 * x + c12 * y + c13 ) * (0.5 + 0.5 * c) + sin(c21 * x + c22 * y + c23 ) * (0.5 - 0.5 * c);
	
	//TODO: Add complexity factor
	//TODO: add some way to adjust the random values
	
	ALBEDO = vec3(grey, grey, grey);
	ALPHA = 1.0;
}
