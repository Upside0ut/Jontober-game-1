extends Node

const levels = [
	preload("res://levels/level_01.tscn"),
	preload("res://levels/level_02.tscn"),
	preload("res://levels/level_03.tscn"),
	preload("res://levels/level_04.tscn"),
	preload("res://scenes/end.tscn")
]

var level = 1

var global_time = 0.0

func _process(delta: float) -> void:
	global_time += delta
