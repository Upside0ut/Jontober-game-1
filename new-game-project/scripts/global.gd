extends Node

const levels = [
	"res://levels/level_01.tscn",
	"res://levels/level_02.tscn",
	"res://levels/level_03.tscn",
	"res://levels/level_04.tscn",
	"res://scenes/end.tscn"
]

var level = 1

var global_time = 0.0

func _process(delta: float) -> void:
	global_time += delta
	
	# if you guys use any shaders, use 'global uniform float global_shadertime' instead of TIME
	RenderingServer.global_shader_parameter_set("global_shadertime", global_time)
