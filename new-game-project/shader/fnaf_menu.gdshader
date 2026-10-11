shader_type canvas_item;

uniform bool should_change = false;
uniform float alpha = 1.0;
uniform float inner_radius = 0.0;
uniform float outer_radius = 1.0;

void fragment() {
	
	
	
	float x = abs(UV.r-.5)*2.0;
	float y = abs(UV.g-.5)*2.0;
	float q = 0.0;
	
	
	if (should_change)
	{
		float changing = mix(0.9,1.1,abs(sin(TIME*2.0)));
		q = 1.0-(1.0-sqrt(x*x+y*y)/changing+0.2)/(1.0-inner_radius);
	}
	else
	{
		q = 1.0-(1.0-sqrt(x*x+y*y)/outer_radius+0.2)/(1.0-inner_radius);
	}
	
	COLOR = vec4(0, 0, 0, q*alpha);
}