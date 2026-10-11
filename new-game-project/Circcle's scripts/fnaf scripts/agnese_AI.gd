extends Node2D

signal jumpscare

@export var door_sprite : Sprite2D
@export var ai_level := 20            # 0-20, obviously :)
@export var move_interval := 6.0     # seconds between movement opportunities
@export var attack_time := 6.0       # how long they wait before jumpscaring

@export var root_node : Node2D
@export var time_to_repel := 2.0        # seconds of light needed for him to move

var alarm_time := 0.0

@export var use_difficulty := true # should use the nightdata difficutly stuff
var jumpscared := false

@export var walk_audios : AudioStreamPlayer2D

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
	if use_difficulty: set_difficulty()
	
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
						walk_audios.play()
						
					print("Agnese moved: ", amount_before_appear)
					# amount of times the AI needs to roll successfully to appear
					if amount_before_appear >= 3:
						_appear_at_entrance()
						amount_before_appear = 0
		
		State.AT_DOOR:
			if root_node.alarm_turned_on:
				alarm_time += delta
				if alarm_time >= time_to_repel:
					_remove_from_entrance()
					return
			else:
				alarm_time = 0.0
			
			if !root_node.alarm_pauses_attack or !root_node.alarm_turned_on:
				attack_left -= delta
				print("Agnese attack time: ", attack_left)
			if attack_left <= 0.0:
				if jumpscared: return
				jumpscared = true
				get_parent().set_process(false)
				door_sprite.visible = false
				jumpscare.emit("Agnese")
				print("Agnese Jumpscare")

func _appear_at_entrance() -> void:
	attack_left = attack_time
	state = State.AT_DOOR
	door_sprite.visible = true
	
	print("- Agnese at door!")
	
	$Enter_SFX.play()
	# warning sound here

func _remove_from_entrance() -> void:
	if state != State.AT_DOOR:
		return
	state = State.AWAY
	door_sprite.visible = false
	#alarm_time = 0.0
	move_timer = move_interval + randf_range(0.0, 3.0) # randomize when she moves again
	
	print("- Agnese left.")
	# leaving sound here
