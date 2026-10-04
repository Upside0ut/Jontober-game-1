extends Node2D

@export var bottom_areas : Node
@onready var drop_marker : Node2D = $"Drop Marker"
@onready var plinko_player : Node2D = $"Plinko Player"
@onready var player_camera : Node2D = $"Player Camera"
@onready var background : ColorRect = $"gambling bg"
@export var state_text : RichTextLabel

@export var fnaf_ver := false
var error_chance := 0.0

signal game_won
signal game_lost
var game_ended : bool = false

var ready_to_reset : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(drop_marker != null, "Plinko State Handler didn't find Drop Marker!")
	assert(plinko_player != null, "Plinko State Handler didn't find Plinko Player!")
	assert(player_camera != null, "Plinko State Handler didn't find Player Camera!")
	
	for child in bottom_areas.get_children():
		child.changed_state.connect(_on_state_changed.bind(child))
	
	if fnaf_ver:
		for peg in get_tree().get_nodes_in_group("pegs"):
			if is_ancestor_of(peg):
				peg.peg_clicked.connect(_on_peg_clicked)
		
		background.visible =false
	state_text.text = ""

#region FNAF_stuff
# YOU CAN ONLY DISABLE PEGS IN THE FNAF MODE (i suppose that could change later)
# but do not touch this
var disabled_peg : Node = null
func _on_peg_clicked(peg) -> void:
	if fnaf_ver:
		
		# turns already disabled peg on
		if peg == disabled_peg:
			peg.set_disabled(false)
			disabled_peg = null
			return
		
		# turns disabled peg back on if u clicked another one
		if disabled_peg:
			disabled_peg.set_disabled(false)
			
		# and turns this one off
		peg.set_disabled(true)
		disabled_peg = peg
#endregion

func _on_state_changed(area):
	if !fnaf_ver:
		if game_ended: return
	
	if area is Victory_Area:
		print("Plinko: Game Won!")
		state_text.text = "Good job! You Won!"
		
		_reset_all()
		game_won.emit()
		
		if !fnaf_ver:
			drop_marker.can_drop = false
		else:
			_reset_after_timer()
		
		game_ended = true
		
	elif area is Lose_Area:
		print("Plinko: Game Lost!")
		state_text.text = "Oh no! You lost!"
		
		_reset_all()
		if !fnaf_ver:
			drop_marker.can_drop = false
			await get_tree().create_timer(3.0).timeout
		else:
			_reset_after_timer()
		game_lost.emit()
		
		game_ended = true
		
	elif area is Neutral_Area:
		print("Plinko: Game Neutral!")
		
		state_text.text = "You didn't hit anything, try again!"
		_reset_after_timer()

func _reset_after_timer():
	if ready_to_reset: return
	ready_to_reset = true
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
