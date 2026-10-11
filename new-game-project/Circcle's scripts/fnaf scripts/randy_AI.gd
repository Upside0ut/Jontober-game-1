extends Node2D

signal jumpscare

@export var door_sprite : Sprite2D
@export var ai_level := 20            # 0-20, obviously :)
@export var move_interval := 5.0     # seconds between movement opportunities
@export var attack_time := 6.0       # how long they wait before jumpscaring

@export var root_node : Node2D
@export var flashlight : Node2D
@export var time_to_repel := 2.0        # seconds of light needed for him to move
@export var light_area : Area2D
var hovered := false
var light_time := 0.0

@export var use_difficulty := true # should use the nightdata difficutly stuff
var jumpscared := false

@export var vent_audios : AudioStreamPlayer2D

enum State {
	AWAY, 
	AT_DOOR
	}

var state := State.AWAY
var move_timer := 0.0
var attack_left := 0.0
var amount_before_appear := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if use_difficulty:  set_difficulty()
	
	light_area.mouse_entered.connect(_on_area_2d_mouse_entered)
	light_area.mouse_exited.connect(_on_area_2d_mouse_exited)
	door_sprite.visible = false
	move_timer = move_interval

func set_difficulty() -> void:
	var data = NightData.get_diff("Agnese")
	ai_level = data["ai_level"]
	move_interval = data["move_interval"]
	attack_time = data["attack_time"]
	time_to_repel = data["time_to_repel"]

func _process(delta: float) -> void:
	match state:
		State.AWAY:
			move_timer -= delta
			if move_timer <= 0.0:
				move_timer = move_interval
				
				# if lower than ai_level = moves
				if randi_range(1, 20) <= ai_level:
					amount_before_appear += 1
					
					if randf() <= 0.5 and amount_before_appear < 3:
						vent_audios.play()
					
					print("Randy moved: ", amount_before_appear)
					# amount of times the AI needs to roll successfully to appear
					if amount_before_appear >= 3:
						_appear_at_entrance()
						amount_before_appear = 0
		
		State.AT_DOOR:
			if hovered and flashlight.visible:
				light_time += delta
				if light_time >= time_to_repel:
					_remove_from_entrance()
					return
			else:
				light_time = 0.0
			
			if !root_node.alarm_pauses_attack or !hovered or !flashlight.visible:
				attack_left -= delta
				print("Randy attack time: ", attack_left)
			if attack_left <= 0.0:
				if jumpscared: return
				jumpscared = true
				get_parent().set_process(false)
				door_sprite.visible = false
				jumpscare.emit("Randy")
				print("Randy Jumpscare")

func _on_area_2d_mouse_entered() -> void:
	hovered = true

func _on_area_2d_mouse_exited() -> void:
	hovered = false

func _appear_at_entrance() -> void:
	attack_left = attack_time
	state = State.AT_DOOR
	door_sprite.visible = true
	
	print("- Randy at vent!")
	
	$Enter_SFX.play()
	# warning sound here

func _remove_from_entrance() -> void:
	if state != State.AT_DOOR:
		return
	state = State.AWAY
	door_sprite.visible = false
	move_timer = move_interval + randf_range(0.0, 3.0) # randomize when she moves again
	
	print("- Randy left.")
	# leaving sound here
