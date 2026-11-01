extends Node2D

func _ready() -> void:
	var config = ConfigFile.new()
	var err: Error = config.load("user://levels.cfg")
	if err != OK:
		return
	
	if (config.get_value("LEVELS", Global.level4_hard.lvl_name) == true):
		pass
		#maybe make it so you dont come in, but then what if you wanna replay it... idk so leaving this

func _on_door_just_opened() -> void:
	await wait(0.1)
	Global.switch_to_b_route()
	Global.reset_checkpoint()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
