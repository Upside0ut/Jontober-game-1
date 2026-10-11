extends Control

@export var fading_red : ColorRect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if fading_red.modulate.a <= 0:
		if NightData.custom_night:
			get_tree().change_scene_to_file("res://scenes/custom_night_menu.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/fnaf_menu.tscn")
