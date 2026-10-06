extends Node2D

var a = Vector2(300, 20)

var possibleOpeningPositions = [
	Vector2(0, -300), #top
	Vector2(200, -200), #top right
	Vector2(300, 0), #right
	Vector2(200, 200), #bottom right
	Vector2(0, 300), #bottom
	Vector2(-200, 200), #bottom-left
	Vector2(-300, 0), #left
	Vector2(-200, -200) #top-left
	]

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_opening()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_random_ring_position():
	return possibleOpeningPositions.pick_random()

func create_random_opening():
	get_node("OpeningArea").position = possibleOpeningPositions.pick_random()

func create_opening(index):
	get_node("OpeningArea").position = possibleOpeningPositions.get(index)

func close_opening():
	get_node("OpeningArea").position = Vector2(0, 0)
