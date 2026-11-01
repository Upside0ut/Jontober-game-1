extends VBoxContainer

func _on_play_pressed() -> void:
	Global.change_to_level(Global.level1)

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_lvl_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_selection_screen.tscn")

func _on_skins_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/skin_selection_screen.tscn")
