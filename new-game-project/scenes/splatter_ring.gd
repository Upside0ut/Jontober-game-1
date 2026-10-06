extends Node2D

var a = Vector2(300, 20)

var ring_positions = [
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
	return ring_positions.pick_random()

func get_nearest_ring_position_to(target_position: Vector2):
	var closest_position
	var closest_distance = INF

	for p in ring_positions:
		var distance = target_position.distance_to(p)
		if distance < closest_distance:
			closest_distance = distance
			closest_position = p
			
	print(closest_position)
	return closest_position

func create_random_opening():
	get_node("OpeningArea").position = ring_positions.pick_random()

func create_opening(index):
	get_node("OpeningArea").position = ring_positions.get(index)

func close_opening():
	get_node("OpeningArea").position = Vector2(0, 0)
