extends Node


@export var button_array: Array[Control]
var level_array: Array[String] = ["lvl_1", "lvl_2", "lvl_3", "lvl_4", "lvl_5", "lvl_6"]

func _ready() -> void:
	var config = ConfigFile.new()
	var err: Error = config.load("user://levels.cfg")
	for n in level_array.size():
		if config.get_value("LEVELS", level_array[n]):
			button_array[n].disabled = false
			

func _on_lvl1_press() -> void:
	get_tree().change_scene_to_file("res://levels/level_01.tscn")

func _on_lvl2_press() -> void:
	get_tree().change_scene_to_file("res://levels/level_02.tscn")

func _on_lvl3_press() -> void:
	get_tree().change_scene_to_file("res://levels/level_03.tscn")

func _on_lvl4_press() -> void:
	get_tree().change_scene_to_file("res://levels/level_04.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
