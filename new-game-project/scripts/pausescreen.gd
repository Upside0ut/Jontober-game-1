extends CanvasLayer

@onready var anim_player = $PauseScreen/AnimationPlayer
@onready var options_menu = $"Options Menu"

func _ready():
	if options_menu == null:
		printerr("Options Menu not under Pause Menu!")
	
	anim_player.play("RESET")
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	on_pause_pressed()

func resume():
	if anim_player.is_playing(): return
	get_tree().paused = false
	anim_player.play_backwards("blur")
	await anim_player.animation_finished
	hide()

func pause():
	get_tree().paused = true
	anim_player.play("blur")
	show()

func on_pause_pressed():
	if anim_player.is_playing(): return
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

func _on_continue_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	await resume()
	# then go to options.
	options_menu.options_opened()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")
