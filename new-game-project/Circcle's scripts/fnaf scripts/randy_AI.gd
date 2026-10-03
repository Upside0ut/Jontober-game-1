extends Node2D

signal jumpscare

@export var door_sprite : Sprite2D
@export var ai_level := 8            # 0-20, obviously :3
@export var move_interval := 4.0     # seconds between movement opportunities
@export var attack_time := 6.0       # how long they wait before jumpscaring

@export var flashlight : Node2D
@export var time_to_repel := 2.0        # seconds of light needed for him to move
@export var light_area : Area2D
var hovered := false
var light_time := 0.0

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
	light_area.mouse_entered.connect(_on_area_2d_mouse_entered)
	light_area.mouse_exited.connect(_on_area_2d_mouse_exited)
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
					print("Randy moved: ", amount_before_appear)
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
			
			attack_left -= delta
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
	state = State.AT_DOOR
	attack_left = attack_time
	door_sprite.visible = true
	
	print("- Randy at vent!")
	# warning sound here

func _remove_from_entrance() -> void:
	if state != State.AT_DOOR:
		return
	state = State.AWAY
	door_sprite.visible = false
	move_timer = move_interval + randf_range(0.0, 3.0) # randomize when she moves again
	
	print("- Randy left.")
	# leaving sound here
