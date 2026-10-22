extends Node

var checkbox_array: Array[Control]

@export var default_skin : CheckBox
var turned_on : CheckBox 

func _ready() -> void:
	
	for child : CheckBox in get_children():
		checkbox_array.append(child)
	
	Global.achievement_changed.connect(full_setup)
	Global.achievements_cleared.connect(full_setup)
	full_setup()

func full_setup():
	set_current_skin()
	var skins_dict = make_skins_dict()
	if skins_dict != null:
		autoadd_checkboxes(skins_dict)
	else:
		printerr("skins_dict came back as null!")

func set_current_skin():
	if Global.current_skin_name:
		
		for node in checkbox_array:
			if node.name == Global.current_skin_name:
				turned_on = node
				turned_on.button_pressed = true
				return
	else:
		turned_on = default_skin
		turned_on.button_pressed = true

func make_skins_dict():
	var config = ConfigFile.new()
	var err: Error = config.load("user://achievements.cfg")
	if err != OK:
		return null
		
	var skins_dict : Dictionary = config.get_value("unlocked_skins", "skins_key")
	return skins_dict

func autoadd_checkboxes(skins_dict : Dictionary):
	for n in Global.skins.size():
		if skins_dict.has(checkbox_array[n].name) and skins_dict[checkbox_array[n].name]:
			checkbox_array[n].disabled = false
		checkbox_array[n].text = "  " + checkbox_array[n].name.capitalize()
		if not checkbox_array[n].is_connected("pressed",_on_pressed):
			checkbox_array[n].pressed.connect(_on_pressed.bind(checkbox_array[n]))

func _on_pressed(pressed_node):
	if turned_on != pressed_node:
		if turned_on != null:
			turned_on.button_pressed = false
		turned_on = pressed_node
	else:
		turned_on = null
	
	if turned_on == null:
		turned_on = default_skin
		turned_on.button_pressed = true
	
	Global.current_skin_name = turned_on.name
	Global.current_skin_png = turned_on.icon
	print(Global.current_skin_name)
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
