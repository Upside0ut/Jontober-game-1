extends CanvasLayer

@export var window_type : OptionButton
@export var volume_slider : HSlider
@export var apply_button : Button
@export var back_button : Button

@onready var pause_menu : CanvasLayer = get_parent()

var config = ConfigFile.new()
var config_path = "user://settings.cfg"

func options_opened():
	get_tree().paused = true
	$"Options Screen/AnimationPlayer".play("blur")
	show()

func options_closed():
	if $"Options Screen/AnimationPlayer".is_playing(): return
	get_tree().paused = false
	$"Options Screen/AnimationPlayer".play_backwards("blur")
	await $"Options Screen/AnimationPlayer".animation_finished
	hide()
	
	if pause_menu: pause_menu.pause()

func _ready():
	apply_button.pressed.connect(_on_apply)
	back_button.pressed.connect(options_closed)
	load_options()
	hide()

func load_options():
	if config.load("user://settings.cfg") != OK:
		return
	
	var saved_type = config.get_value("Window_Type", "type", "windowed")
	var saved_volume = config.get_value("Volume", "volume_linear", 1.0)
	
	for i in range(window_type.item_count):
		if window_type.get_item_text(i).to_lower() == saved_type:
			window_type.select(i)
	
	volume_slider.value = saved_volume
	apply_window_type(saved_type)
	AudioServer.set_bus_volume_linear(0, saved_volume)

func save_options():
	var selected_type = window_type.get_item_text(window_type.selected).to_lower()
	
	config.set_value("Window_Type", "type", selected_type)
	config.set_value("Volume", "volume_linear", volume_slider.value)
	config.save(config_path)

func _on_apply():
	save_options()
	load_options()

func apply_window_type(selected_type):
	match selected_type:
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"exclusive fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		"windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
