extends Camera2D

var starting_position : Vector2 = Vector2.ZERO
var follow_player : bool = false

# check the player ball script for the good debug comment
@onready var drop_marker : Node2D = $"../Drop Marker"
@onready var plinko_player : Node2D = $"../Plinko Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	assert(drop_marker != null, "Drop Marker not found inside Level 02! Has the node been renamed?")
	assert(plinko_player != null, "Plinko Player not found inside Level 02! Has the node been renamed?")
	
	starting_position = global_position
	limit_bottom = 2300
	drop_marker.connect("dropped",_on_ball_dropped)

func _on_ball_dropped():
	follow_player = true

func _reset_camera():
	follow_player = false
	global_position = starting_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if follow_player:
		if global_position.y < plinko_player.global_position.y:
			global_position.y = plinko_player.global_position.y
