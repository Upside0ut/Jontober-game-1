extends Node2D

const SPEED = 220
const HIGHEST_POSITION_Y = -6200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position.y = get_parent().get_node("Player").position.y + 1000


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(global_position.y > HIGHEST_POSITION_Y):
		global_position.y -= delta * SPEED
