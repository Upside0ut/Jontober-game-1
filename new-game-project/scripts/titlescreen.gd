extends VBoxContainer


func _ready() -> void:
	if FileAccess.file_exists("user://levels.cfg"):
		pass
	else:
		var config = ConfigFile.new()
		config.set_value("LEVELS", "lvl_1", "false")
		config.set_value("LEVELS", "lvl_2", "false")
		config.set_value("LEVELS", "lvl_3", "false")
		config.set_value("LEVELS", "lvl_4", "false")
		config.set_value("LEVELS", "lvl_5", "false")
		config.set_value("LEVELS", "lvl_6", "false")
		config.save("user://levels.cfg")
	

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/comic.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_lvl_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_selection_screen.tscn")
