extends Node2D

var a = Vector2(300, 20)

var possibleOpeningPositions = [
	Vector2(-300, 0),
	Vector2(300, 0),
	Vector2(0, -300),
	Vector2(0, 300),
	
	Vector2(-200, -200),
	Vector2(200, 200),
	Vector2(-200, 200),
	Vector2(200, -200)
	]

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_opening()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func create_opening():
	get_node("OpeningArea").position = possibleOpeningPositions.pick_random()

func close_opening():
	get_node("OpeningArea").position = Vector2(0, 0)
