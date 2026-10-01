extends Sprite2D

## Left limit on the x axis
@export var left_limit : float = -900.0
## Right limit on the x axis
@export var right_limit : float = 900.0

## Good for debugging and also it adds some visual polish for how I'm doing this
@export var should_move : bool = true

var going_right : bool = true
var move_speed : float = 1000.0

var currently_dropped : bool = false
signal dropped

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# emits the signal to drop the ball
	if Input.is_action_just_pressed("jump") and not currently_dropped:
		dropped.emit()
		should_move = false
	
	global_position = global_position.round()
	
	if should_move:
		if going_right:
			move_to(right_limit,delta)
			if global_position.x >= right_limit:
				going_right = false
		else:
			move_to(left_limit,delta)
			if global_position.x <= left_limit:
				going_right = true

func move_to(target_position_x, delta):
	if is_equal_approx(global_position.x, target_position_x): return
	global_position.x =\
	 move_toward(global_position.x, target_position_x, move_speed * delta)
