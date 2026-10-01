extends Node2D

@export var bottom_areas : Node
@onready var drop_marker : Node2D = $"Drop Marker"
@onready var plinko_player : Node2D = $"Plinko Player"
@onready var player_camera : Node2D = $"Player Camera"
@export var state_text : RichTextLabel

signal game_won
signal game_lost

var ready_to_reset : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(drop_marker != null, "Plinko State Handler didn't find Drop Marker!")
	assert(plinko_player != null, "Plinko State Handler didn't find Plinko Player!")
	assert(player_camera != null, "Plinko State Handler didn't find Player Camera!")
	
	for child in bottom_areas.get_children():
		child.changed_state.connect(_on_state_changed.bind(child))
	
	state_text.text = ""

func _on_state_changed(area):
	if area is Victory_Area:
		print("Plinko: Game Won!")
		state_text.text = "Good job! You Won!"
		await get_tree().create_timer(1.5).timeout
		game_won.emit()
		
	elif area is Lose_Area:
		print("Plinko: Game Lost!")
		state_text.text = "Oh no! You lost!"
		
		await get_tree().create_timer(3.0).timeout
		game_lost.emit()
		
	elif area is Neutral_Area:
		print("Plinko: Game Neutral!")
		
		state_text.text = "You didn't hit anything, try again!"
		ready_to_reset = true
		
	_reset_all()

func _process(delta: float) -> void:
	if ready_to_reset:
		_reset_after_timer()

func _reset_after_timer():
	_reset_all()
	drop_marker.can_drop = false
	await get_tree().create_timer(3.0).timeout
	drop_marker.can_drop = true
	ready_to_reset = false
	state_text.text = ""

func _reset_all():
	player_camera._reset_camera()
	plinko_player._reset_player()
	drop_marker._reset_marker()
