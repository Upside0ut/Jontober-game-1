extends Control

@export var timer : Timer

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://levels/level_boss.tscn")
