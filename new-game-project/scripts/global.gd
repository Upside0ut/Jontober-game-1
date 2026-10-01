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
