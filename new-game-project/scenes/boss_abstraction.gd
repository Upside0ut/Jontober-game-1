extends CharacterBody2D

enum States {IDLE, HUNTING, ATTACKING}
var state = States.IDLE

var move_speed = 1000

func changeState(newState):
	state = newState
	
	match state:
		States.IDLE:
			idle()
		States.HUNTING:
			hunting()
		States.ATTACKING:
			attacking()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	changeState(States.IDLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO

	match state:
		States.HUNTING:
			hunting()
		States.ATTACKING:
			attacking()

	move_and_slide()

func idle():
	await wait(2)
	get_node("SplatterRing").create_opening()
	await wait(3)
	get_node("SplatterRing").close_opening()
	changeState(States.HUNTING)

func hunting():
	if (find_player_distance() > 500):
		move_toward_player()
	else:
		changeState(States.IDLE)

func attacking():
	pass


func move_toward_player():
	velocity = find_player_direction() * move_speed

func find_player_direction():
	return global_position.direction_to(get_parent().get_node("Player").global_position)

func find_player_distance():
	return global_position.distance_to(get_parent().get_node("Player").global_position)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
