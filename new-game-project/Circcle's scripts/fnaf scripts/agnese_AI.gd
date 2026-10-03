extends Node2D

signal jumpscare



@export var door_sprite : Sprite2D
@export var ai_level := 8            # 0-20, obviously :3
@export var move_interval := 6.0     # seconds between movement opportunities
@export var attack_time := 6.0       # how long they wait before jumpscaring

@export var root_node : Node2D
@export var time_to_repel := 2.0        # seconds of light needed for him to move
var alarm_time := 0.0

var jumpscared := false

enum State {
	AWAY, 
	AT_DOOR
	}

var state := State.AWAY
var move_timer := 0.0
var attack_left := 0.0
var amount_before_appear := 3 # amount of times the AI needs to roll successfully to appear

func _ready() -> void:
	door_sprite.visible = false
	move_timer = move_interval

func _process(delta: float) -> void:
	match state:
		State.AWAY:
			move_timer -= delta
			if move_timer <= 0.0:
				move_timer = move_interval
				
				# if lower than ai_level = moves
				if randi_range(1, 20) <= ai_level:
					amount_before_appear += 1
					print("Agnese moved: ", amount_before_appear)
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
			
			if !root_node.alarm_pauses_attack:
				attack_left -= delta
			if attack_left <= 0.0:
				if jumpscared: return
				jumpscared = true
				get_parent().set_process(false)
				door_sprite.visible = false
				jumpscare.emit("Agnese")
				print("Agnese Jumpscare")

func _appear_at_entrance() -> void:
	state = State.AT_DOOR
	attack_left = attack_time
	door_sprite.visible = true
	
	print("- Agnese at door!")
	# warning sound here

func _remove_from_entrance() -> void:
	if state != State.AT_DOOR:
		return
	state = State.AWAY
	door_sprite.visible = false
	move_timer = move_interval + randf_range(0.0, 3.0) # randomize when she moves again
	
	print("- Agnese left.")
	# leaving sound here
