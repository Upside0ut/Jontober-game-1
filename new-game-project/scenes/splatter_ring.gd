extends Node2D

var a = Vector2(300, 20)

var rng = RandomNumberGenerator.new()

var opening_top
var opening_top_right
var opening_right
var opening_bottom_right
var opening_bottom
var opening_bottom_left
var opening_left
var opening_top_left

var opening_array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	opening_top = get_node("OpeningTop")
	opening_top_right = get_node("OpeningTopRight")
	opening_right = get_node("OpeningRight")
	opening_bottom_right = get_node("OpeningBottomRight")
	opening_bottom = get_node("OpeningBottom")
	opening_bottom_left = get_node("OpeningBottomLeft")
	opening_left = get_node("OpeningLeft")
	opening_top_left = get_node("OpeningTopLeft")
	
	opening_array = [
		opening_top,
		opening_top_right,
		opening_right,
		opening_bottom_right,
		opening_bottom,
		opening_bottom_left,
		opening_left,
		opening_top_left
	]
	close_openings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_nearest_global_ring_position_to(target_position: Vector2):
	var closest_node
	var closest_distance = INF
	
	for o in opening_array:
		var distance = target_position.distance_to(o.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_node = o
	
	return closest_node.global_position

func create_random_opening():
	opening_array.pick_random().show()

func create_opening(index):
	opening_array.get(index).show()

func close_openings():
	for o in opening_array:
		o.hide()
