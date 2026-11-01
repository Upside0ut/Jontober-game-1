extends Node2D

func _ready() -> void:
	var config = ConfigFile.new()
	var err: Error = config.load("user://levels.cfg")
	if err != OK:
		return
	
	if (config.get_value("LEVELS", Global.level4_hard.lvl_name) == true):
		$door.opened = true

func _on_door_just_opened() -> void:
	await wait(0.1)
	Global.switch_to_b_route()
	Global.reset_checkpoint()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
