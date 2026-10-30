extends Node2D

@export var current_level: int = 0
func _ready() -> void:
	Global.level = current_level
	print("Current level:", Global.level)
