extends Control

@export var fader : ColorRect

@export var agnese_diff : HBoxContainer
@export var randy_diff : HBoxContainer
@export var plinko_time_advance : CheckButton
@export var alarm_stall : CheckButton
@export var flash_stall : CheckButton
@export var error_chance_text : LineEdit

var clicked_play := false

var agnese_level := 0
var randy_level := 0
var plinko_timeskip := true
var should_alarmstall := true
var should_flashstall := true
var error_chance := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#222222")
	style.set_content_margin_all(6)
	
	theme = Theme.new()
	theme.set_stylebox("panel", "TooltipPanel", style)
	theme.set_color("font_color", "TooltipLabel", Color.WHITE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	agnese_level = agnese_diff.current_diff
	randy_level = randy_diff.current_diff
	plinko_timeskip = plinko_time_advance.button_pressed
	should_alarmstall = alarm_stall.button_pressed
	should_flashstall = flash_stall.button_pressed
	error_chance = error_chance_text.error_chance
	
	NightData.bronze_active = matches_preset(20, 20, true, true, true, 0.33)
	NightData.silver_active = matches_preset(20, 20, false, true, true, 1.0)
	NightData.gold_active = matches_preset(20, 20, false, false, false, 1.0)

func matches_preset(agnese: int, randy: int, plinko: bool, alarm: bool, flash: bool, error: float) -> bool:
	return agnese_level == agnese \
		and randy_level == randy \
		and plinko_timeskip == plinko \
		and should_alarmstall == alarm \
		and should_flashstall == flash \
		and is_equal_approx(error_chance, error)

func set_challenge_diff(diff : String):
	match diff:
		"bronze":
			agnese_diff.current_diff = 20
			randy_diff.current_diff = 20
			plinko_time_advance.button_pressed = true
			alarm_stall.button_pressed = true
			flash_stall.button_pressed = true
			error_chance_text.text = "33%"
			error_chance_text.error_chance = 0.33
			NightData.start_custom(20, 20, 0.33, true, true, true)
		"silver":
			agnese_diff.current_diff = 20
			randy_diff.current_diff = 20
			plinko_time_advance.button_pressed = false
			alarm_stall.button_pressed = true
			flash_stall.button_pressed = true
			error_chance_text.text = "100%"
			error_chance_text.error_chance = 1.0
			NightData.start_custom(20, 20, 1.0, false, true, true)
		"gold":
			agnese_diff.current_diff = 20
			randy_diff.current_diff = 20
			plinko_time_advance.button_pressed = false
			alarm_stall.button_pressed = false
			flash_stall.button_pressed = false
			error_chance_text.text = "100%"
			error_chance_text.error_chance = 1.0
			NightData.start_custom(20, 20, 1.0, false, false, false)

func _on_bronze_pressed() -> void:
	set_challenge_diff("bronze")

func _on_silver_pressed() -> void:
	set_challenge_diff("silver")

func _on_gold_pressed() -> void:
	set_challenge_diff("gold")

func fade_then_change(scene_path : String) -> void:
	if clicked_play: return
	clicked_play = true
	
	fader.fade_out_by_default = false
	fader.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fader, "modulate:a", 1.0, 0.3)
	await tween.finished
	
	get_tree().change_scene_to_file(scene_path)

func _on_button_pressed() -> void:
	NightData.start_custom(agnese_level, randy_level, error_chance, plinko_timeskip, should_alarmstall, should_flashstall)
	fade_then_change("res://scenes/fnaf_level.tscn")

func _on_back_pressed() -> void:
	fade_then_change("res://scenes/fnaf_menu.tscn")
