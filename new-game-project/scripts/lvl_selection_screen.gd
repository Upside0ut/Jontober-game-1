extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
