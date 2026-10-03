extends Node


@export var button_array: Array[Control]
var level_array: Array[String] = ["lvl_1", "lvl_2", "lvl_3", "lvl_4", "lvl_5", "lvl_6"]

func _ready() -> void:
	var config = ConfigFile.new()
	var err: Error = config.load("user://levels.cfg")
	if err != OK:
		return
	for n in level_array.size():
		if config.get_value("LEVELS", level_array[n]) == true:
			button_array[n].disabled = false

func go_to_level(path: String):
	get_tree().change_scene_to_file(path)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
