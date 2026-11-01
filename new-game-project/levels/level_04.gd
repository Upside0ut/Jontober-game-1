extends Node2D

func _on_door_just_opened() -> void:
	await wait(0.1)
	Global.switch_to_b_route()
	Global.reset_checkpoint()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
