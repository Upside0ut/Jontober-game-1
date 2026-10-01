extends Camera2D

var starting_position : Vector2 = Vector2.ZERO
var follow_player : bool = false

# check the player ball script for the good debug comment
@onready var drop_marker : Node2D = $"../Drop Marker"
@onready var player_ball : Node2D = $"../Player Ball"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	assert(drop_marker != null, "Drop Marker not found inside Level 02! Has the node been renamed?")
	assert(player_ball != null, "Player Ball not found inside Level 02! Has the node been renamed?")
	
	starting_position = global_position
	limit_bottom = 2300
	drop_marker.connect("dropped",_on_ball_dropped)

func _on_ball_dropped():
	follow_player = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if follow_player:
		if global_position.y < player_ball.global_position.y:
			global_position.y = player_ball.global_position.y
