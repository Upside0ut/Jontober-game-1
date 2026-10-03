extends Node2D

@export var current_level: int = 1
func _ready() -> void:
	Global.level = current_level
	print(Global.level)
