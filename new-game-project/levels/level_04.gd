extends Node2D

func _process(delta) -> void:
	if ($door.opened):
		await wait(0.2)
		get_tree().change_scene_to_file("res://levels/level_04_hard_version.tscn")


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
