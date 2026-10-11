class_name FNAF_HANDLER
extends Node2D

@export_group("Enemies")
@export var Agnese : Node2D
@export var Randy : Node2D

@export_group("Difficulty")
@export var plinko_night_advance := true # reduce night length by 10 seconds
@export var alarm_pauses_attack := true # pauses attack as in you cant be
@export var flash_pauses_attack := true # killed during doing these
@export var night_length := 270.0 # 270.0 is the same as UCN
@export var error_chance := 0.1 # percentage, for disabling the pegs

@export_group("Nodes")
@export var alarm_light : Node2D
@export var alarm_rope : Node2D
@export var fnaf_pad : CanvasLayer
@export var rage_bar : ProgressBar
@export var pad_opener : Control
@export var night_timer : RichTextLabel
@export var sixam_text : RichTextLabel
@export var fade_animation : AnimationPlayer

# I'm realizing how DUMB I am for programming this to be this way so I'm
# using this to disable everything once the night's over
@export var gameplay_parent : Node2D 

@export_group("Audio Nodes")
@export var drone : AudioStreamPlayer
@export var hour_tonk : AudioStreamPlayer
@export var weird_clanking : AudioStreamPlayer
@export var victory_jingle : AudioStreamPlayer
@export var ambient_audios : AudioStreamPlayer

var passed_time := 0.0
var level_2_child_scene : Node2D
var pad_open := false
var alarm_turned_on := false
var current_hour := 0
var last_hour := 0

var night_won := false
var night_lost := false

var countdown := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if NightData.custom_night:
		alarm_pauses_attack = NightData.get_diff("alarm_stall")
		flash_pauses_attack = NightData.get_diff("flash_stall")
		plinko_night_advance = NightData.get_diff("plinko_night_advance")
	error_chance = NightData.get_diff("error_chance")
	
	pad_opener.mouse_entered.connect(_on_pad_opener)
	
	fnaf_pad.plinko_won.connect(_on_plinko_won)
	fnaf_pad.plinko_lost.connect(_on_plinko_lost)
	
	alarm_rope.alarm_on.connect(_alarm_on)
	alarm_rope.alarm_off.connect(_alarm_off)
	
	level_2_child_scene = fnaf_pad.plinko_subviewport.get_child(0)
	
	sixam_text.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if night_won: 
		weird_clanking.pitch_scale = clampf(weird_clanking.pitch_scale - delta*0.03, 0.01, 1.0)
		weird_clanking.volume_linear = clampf(weird_clanking.volume_linear - delta*0.03, 0.00, 1.0)
		drone.volume_linear = clampf(drone.volume_linear - delta*0.03, 0.00, 1.0)
		return
			
	#this is to play a sound when the hour changes
	hour_checker()
	
	#playing random ambience every now and then
	countdown -= delta
	if countdown <= 0.0:
		ambient_audios.play()
		countdown = randf_range(8.0, 25.0)
	
	passed_time = clamp(passed_time,0.0,night_length)
	if passed_time >= night_length:
		gameplay_parent.process_mode = Node.PROCESS_MODE_DISABLED
		fnaf_pad.process_mode = Node.PROCESS_MODE_DISABLED
		win_night()
		night_won = true
	else:
		passed_time += delta
		
		
		current_hour = int(passed_time/(night_length/6))
		night_timer.text = "(%dAM) %02d:%02d" % [
			12 if current_hour == 0 else current_hour,
			int(passed_time/60), 
			int(passed_time)%60
			]

func hour_checker():
	if current_hour != last_hour:
		last_hour = current_hour
		if current_hour == 6:
			weird_clanking.play()
			victory_jingle.play()
		else:
			hour_tonk.play()

func win_night():
	fade_animation.play("fade_in")
	await get_tree().create_timer(2.0).timeout
	await animate_sixam_text()
	await get_tree().create_timer(5.0).timeout
	if !NightData.custom_night:
		NightData.current_night += 1
	else:
		if NightData.bronze_active:
			NightData.beaten_bronze_mode = true
		elif NightData.silver_active:
			NightData.beaten_silver_mode = true
		elif NightData.gold_active:
			NightData.beaten_gold_mode = true
		
	NightData.save_night()
	
	if NightData.custom_night:
		get_tree().change_scene_to_file("res://scenes/custom_night_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/fnaf_menu.tscn")
	
	print("Night Done!")

func animate_sixam_text():
	sixam_text.text = ""
	sixam_text.visible = true
	
	for i in "6:00 AM":
		await get_tree().create_timer(0.1).timeout
		sixam_text.text += i
	await get_tree().create_timer(3.0).timeout
	
	#the shader has a random noise size so im using that for variance
	sixam_text.material.set_shader_parameter("noise_scale", randf_range(22.0,64.0))
	var tween = create_tween()
	tween.tween_property(sixam_text.material, "shader_parameter/dissolve", 1.0, 4.0)
	return

func _on_plinko_won():
	if !alarm_light.rage_locked and !level_2_child_scene.game_ended:
		level_2_child_scene.game_ended = true
		rage_bar.value -= 20
		
	if plinko_night_advance:
		passed_time += 10.0

func _on_plinko_lost():
	if !alarm_light.rage_locked and !level_2_child_scene.game_ended:
		level_2_child_scene.game_ended = true
		rage_bar.value += 5

func _alarm_on():
	print("ALARM ON")
	alarm_turned_on = true

func _alarm_off():
	print("ALARM OFF")
	alarm_turned_on = false

func _on_pad_opener():
	if fnaf_pad.is_moving: return
	if pad_open:
		fnaf_pad.leave_view()
		print("in")
		pad_open = false
	else:
		print("out")
		fnaf_pad.enter_view()
		pad_open = true
