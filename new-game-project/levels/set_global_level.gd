extends Node2D

@export var current_level: int = 0
func _ready() -> void:
	Global.level = current_level
	print("Current level:", Global.level)

func _process(delta) -> void:
	if ($door.opened):
		await wait(0.2)
		$Player.global_position = Vector2(0, 0)
		get_tree().change_scene_to_file("res://levels/level_04_hard_version.tscn")


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
