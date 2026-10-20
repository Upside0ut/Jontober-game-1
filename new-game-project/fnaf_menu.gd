extends Control

@export var nights : RichTextLabel
@export var fader : ColorRect
@export var song : AudioStreamPlayer

var clicked_play := false

func _ready() -> void:
	NightData.load_night()
	
	var original_volume = song.volume_linear
	song.volume_linear = 0.01
	var tween := create_tween()
	tween.tween_property(song, "volume_linear", original_volume, 0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	nights.text = "Night %s" % str(clampi(NightData.current_night,0,4)+1)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if Input.is_key_pressed(KEY_1) \
		and Input.is_key_pressed(KEY_9) \
		and Input.is_key_pressed(KEY_8) \
		and Input.is_key_pressed(KEY_7):
			get_tree().change_scene_to_file("res://scenes/titlescreen.tscn")

func fade_then_change(scene_path : String) -> void:
	if clicked_play: return
	clicked_play = true
	
	fader.fade_out_by_default = false
	fader.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fader, "modulate:a", 1.0, 0.3)
	tween.tween_property(song, "volume_linear", 0.0, 0.3)
	await tween.finished
	
	get_tree().change_scene_to_file(scene_path)

func _on_button_pressed() -> void:
	NightData.custom_night = false
	fade_then_change("res://scenes/fnaf_level.tscn")

func _on_button_2_pressed() -> void:
	fade_then_change("res://scenes/custom_night_menu.tscn")
