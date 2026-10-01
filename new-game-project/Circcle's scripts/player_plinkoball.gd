extends RigidBody2D

# finds the node with the name 'Drop Marker', if this was changed then the game crashes
# i'll add like an error or something, make sure this matches the node's actual name
#                                            |
#                                            V
@onready var drop_marker : Node2D = $"../Drop Marker"

@export var h_impulse_str : int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# shouts at u if drop_marker returns as null (a.k.a it wasn't found)
	assert(drop_marker != null, "Drop Marker not found inside Level 02! Has the node been renamed?")
	
	freeze = true
	visible = false
	drop_marker.connect("dropped",_on_ball_dropped)

func _on_ball_dropped():
	
	print("Level 2: Ball Dropped!")
	
	freeze = false
	visible = true
	drop_marker.currently_dropped = true
	
	global_position = Vector2(
		drop_marker.global_position.x,
		drop_marker.global_position.y - 800
		)
	linear_velocity = Vector2.ZERO
	
	# balls can balance on eachother perfectly sometimes, i added
	# a microscopic horizontal force (-1 or 1) so that can't happen, cheap fix c:
	# you can test the difference if you want by turning off should_move on the marker
	var impulse_dir = randi_range(0,1)
	if impulse_dir == 0: impulse_dir = -1
	
	apply_impulse(Vector2(impulse_dir * h_impulse_str, 0.0))
