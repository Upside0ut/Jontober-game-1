shader_type canvas_item;

// Shader by muzi1983 
// (https://godotshaders.com/author/muzi1983/)
// https://godotshaders.com/shader/rainbow-flowcanvasitem/

global uniform float global_shadertime;

// added by Circcle
uniform float shader_speed = 0.15;
uniform float shader_saturation = 0.7;
uniform float shader_brightness = 0.4;


vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	float hue = (UV.x+UV.y) * 0.25 + mod(global_shadertime * shader_speed, 1.0);
	//float hue = -UV.y * 0.25 + mod(TIME * 0.25, 1.0);

	COLOR.rgb *= hsv2rgb(vec3(hue,shader_saturation, shader_brightness));
}
