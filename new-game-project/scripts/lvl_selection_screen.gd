extends Node

@onready var btn_lvl_1 = $TITLE/Label/Control/Lvl1
@onready var btn_lvl_2 = $TITLE/Label/Control/Lvl2
@onready var btn_lvl_3 = $TITLE/Label/Control/Lvl3
@onready var btn_lvl_4 = $TITLE/Label/Control/Lvl4
@onready var btn_lvl_5 = $TITLE/Label/Control/Lvl5
@onready var btn_lvl_boss = $TITLE/Label/Control/Lvl6

@onready var btn_to_lvl_dict: Dictionary[Button, Global.Level] = {
	btn_lvl_1: Global.level1,
	btn_lvl_2: Global.level2,
	btn_lvl_3: Global.level3,
	btn_lvl_4: Global.level4,
	btn_lvl_5: Global.level5,
	btn_lvl_boss: Global.level_boss
}

signal zoomed

func _ready() -> void:
	var config = ConfigFile.new()
	var err: Error = config.load("user://levels.cfg")
	if err != OK:
		return
	for btn in btn_to_lvl_dict.keys():
		if Global.check_previous_level_beaten(btn_to_lvl_dict.get(btn)):
			btn.disabled = false
			btn.pressed.connect(go_to_level.bind(btn, btn_to_lvl_dict.get(btn)))

func go_to_level(button : Control, level: Global.Level):
	var button_center = button.get_global_transform() * (button.size / 2.0)
	zoomed.emit(level, button_center)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
