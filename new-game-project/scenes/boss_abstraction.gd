extends Node2D

enum States {IDLE, HUNTING, ATTACKING}

var state = States.IDLE

func changeState(newState):
	state = newState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		States.IDLE:
			idle()
		States.HUNTING:
			hunting()
		States.ATTACKING:
			attacking()

func idle():
	pass

func hunting():
	pass

func attacking():
	pass
