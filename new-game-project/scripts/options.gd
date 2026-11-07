class_name OptionsMenu
extends CanvasLayer

@export var main_screen : OptionButton
@export var window_type : OptionButton
@export var resolution_type : OptionButton
@export var volume_slider : HSlider
@export var apply_button : Button
@export var reset_button : Button
@export var back_button : Button

@onready var pause_menu : CanvasLayer = get_parent() as PauseMenu

var optioning := false
var trying_to_reset := false
var resetting := false
var canceled_reset := false

var config = ConfigFile.new()
var config_path = "user://settings.cfg"

func options_opened():
	get_tree().paused = true
	$"Options Screen/AnimationPlayer".play("blur")
	show()
	optioning = true

func options_closed():
	if $"Options Screen/AnimationPlayer".is_playing(): return
	
	if trying_to_reset:
		trying_to_reset = false
		reset_button.text = "Reset Settings"
	if resetting: 
		canceled_reset = true
		reset_button.text = "Reset Canceled"
	
	get_tree().paused = false
	$"Options Screen/AnimationPlayer".play_backwards("blur")
	await $"Options Screen/AnimationPlayer".animation_finished
	
	#load_options()
	optioning = false
	hide()
	
	if pause_menu: pause_menu.pause()

func _ready():
	apply_button.pressed.connect(_on_apply)
	reset_button.pressed.connect(_on_reset)
	back_button.pressed.connect(options_closed)
	populate_screen_options()
	#load_options()
	hide()

# i realize it sorta late that maybe this shouldve been load_settings()...
func load_options():
	if config.load("user://settings.cfg") != OK:
		reset_settings()
		return
	
	var saved_screen = config.get_value("Window", "main_screen", 0)
	var saved_type = config.get_value("Window", "type", "windowed")
	var saved_res = config.get_value("Window", "resolution", "1152x648")
	var saved_volume = config.get_value("Volume", "volume_linear", 1.0)
	
	set_option_visuals(saved_type,saved_res,saved_volume,saved_screen)
	
	apply_main_screen(saved_screen)
	apply_resolution(saved_res)
	apply_window_type(saved_type)
	AudioServer.set_bus_volume_linear(0, saved_volume)

func save_options():
	var selected_type = window_type.get_item_text(window_type.selected).to_lower()
	var selected_res = resolution_type.get_item_text(resolution_type.selected)
	var selected_screen = main_screen.selected
	
	config.set_value("Window", "main_screen", selected_screen)
	config.set_value("Window", "type", selected_type)
	config.set_value("Window", "resolution", selected_res)
	config.set_value("Volume", "volume_linear", volume_slider.value)
	config.save(config_path)

func _on_apply():
	save_options()
	load_options()

func _on_reset():
	if resetting: return
	
	if not trying_to_reset:
		trying_to_reset = true
		reset_button.text = "Are You Sure?"
		return
		
	
	trying_to_reset = false
	resetting = true
	canceled_reset = false
	reset_button.text = "Resetting"
	
	for i in range(3):
		await get_tree().create_timer(0.75).timeout
		
		if canceled_reset: 
			await get_tree().create_timer(1.5).timeout
			
			resetting = false
			canceled_reset = false
			
			reset_button.text = "Reset Settings"
			return
		reset_button.text += "."
	await get_tree().create_timer(0.75).timeout
	
	reset_button.text = "Successful Reset."
	reset_settings()
	await get_tree().create_timer(0.75).timeout
	
	reset_button.text = "Reset Settings"
	resetting = false
	canceled_reset = false


func reset_settings():
	set_option_visuals()
	save_options()
	#load_options()

func populate_screen_options():
	var screens := DisplayServer.get_screen_count()
	for i in range(screens):
		main_screen.add_item("Display %d" % (i + 1))

func apply_main_screen(selected_screen : int = 0):
	var valid_screen = clampi(selected_screen,0,DisplayServer.get_screen_count()-1)
	DisplayServer.window_set_current_screen(valid_screen)

func apply_resolution(resolution : String = "1152x648"):
	if get_window().mode == Window.MODE_WINDOWED:
		var vec2i_res : Vector2i = Vector2i(
			resolution.split("x")[0].to_int(),
			resolution.split("x")[1].to_int()
			)
		get_window().size = vec2i_res

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

func set_option_visuals(
	saved_type : String = "windowed",
	saved_res : String = "1152x648",
	saved_volume : float = 1.0,
	saved_screen : int = DisplayServer.get_primary_screen()
):
	for i in range(window_type.item_count):
		if window_type.get_item_text(i).to_lower() == saved_type:
			window_type.select(i)
	for i in range(resolution_type.item_count):
		if resolution_type.get_item_text(i) == saved_res:
			resolution_type.select(i)
	for i in range(main_screen.item_count):
		if main_screen.get_item_text(i) == "Display %d" % (saved_screen + 1):
			main_screen.select(i)
	volume_slider.value = saved_volume
	
