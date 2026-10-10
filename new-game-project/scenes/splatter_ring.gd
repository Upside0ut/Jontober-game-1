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
	
	for o in opening_array:
		o.body_entered.connect(_on_opening_body_entered.bind(o))
	
	$spikes.set_deferred("monitorable", true)
	close_openings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_current_opening():
	for o in opening_array:
		if o.visible:
			return o

func get_random_global_ring_position(exclude_current_opening):
	var opening = opening_array.pick_random()
	
	if (exclude_current_opening):
		while get_current_opening() == opening:
			opening = opening_array.pick_random()
	
	return opening.global_position

func get_nearest_global_ring_position_to(target_position: Vector2, exclude_current_opening: bool):
	var closest_node
	var closest_distance = INF
	
	for o in opening_array:
		if (exclude_current_opening):
			if get_current_opening() == o:
				continue
		
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

func _on_opening_body_entered(body: Node2D, opening: Area2D) -> void:
	if(body != get_parent().get_parent().get_node("Player")): #TODO this is ugly af but idk
		return
	if(!opening.visible):
		return
	
	if(get_parent().feinting):
		get_parent().feint_success()
		return
	
	$spikes.set_deferred("monitorable", false)
	get_parent().depleteHealth()
