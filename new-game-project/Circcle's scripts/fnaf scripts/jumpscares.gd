extends Node2D

@export var FNAF_PAD : CanvasLayer

@export var Agnese : Node2D
@export var Agnese_jumpscare : Sprite2D
@export var Randy : Node2D
@export var Randy_jumpscare : Sprite2D

@export var player_cam : Camera2D
@export var jumpscare_light : PointLight2D
@export var jumpscare_sfx : AudioStreamPlayer

var dead := false
var shaking := false
var start_position := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position
	
	jumpscare_light.visible = false
	Agnese.jumpscare.connect(_on_jumpscare)
	Randy.jumpscare.connect(_on_jumpscare)

func _on_jumpscare(enemy):
	if dead: return
	dead = true
	
	match enemy:
		"Agnese":
			Agnese_jumpscare.visible = true
			jumpscare_light.visible = true
		"Randy":
			Randy_jumpscare.visible = true
			jumpscare_light.visible = true
	
	FNAF_PAD.visible = false
	shaking = true
	jumpscare_sfx.pitch_scale = randf_range(.9, 1.1)
	jumpscare_sfx.play()
	
	await get_tree().process_frame
	if Randy_jumpscare.visible and Agnese_jumpscare.visible:
		Randy_jumpscare.visible = false
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shaking:
		player_cam.jumpscare = true
		player_cam.zoom += Vector2.ONE * delta/4.0
		position = start_position + Vector2(
		randf_range(-3.0, 3.0),
		randf_range(-3.0, 3.0)
		)
