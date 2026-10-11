shader_type canvas_item;

global uniform float global_shadertime;

uniform float height = 15.0;
uniform float frequency = 35.0;
uniform float speed = 25.0;

void vertex() {
	VERTEX.y += height * sin((frequency * UV.x) + (speed * global_shadertime));
}
