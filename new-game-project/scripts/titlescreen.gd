extends VBoxContainer

@export var options_menu : CanvasLayer

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/comic.tscn")

func _on_options_pressed() -> void:
	if options_menu:
		if not options_menu.optioning:
			options_menu.options_opened()
		else: 
			options_menu.options_closed()
	else:
		printerr("Titlescreen Buttons VBoxContainer found no Options Menu!")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_lvl_select_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_selection_screen.tscn")

func _on_skins_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/skin_selection_screen.tscn")
