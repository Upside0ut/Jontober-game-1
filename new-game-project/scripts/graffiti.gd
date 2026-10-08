extends Node2D

var line_array: Array[Line2D]
var line: Line2D
var is_drawing: bool
var draw_points_min_distance : float = 5.0

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("click_interact"):
		if !is_drawing:
			is_drawing = true
			var scene: Line2D = Line2D.new()
			line = scene
			add_child(scene)
			scene.default_color = Color(.75, .05, .08)
	else:
		is_drawing = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_drawing and line:
			if line.points.is_empty():
				line.add_point(get_global_mouse_position())
				line_array.append(line)
			elif (line.points[line.get_point_count()-1] - get_global_mouse_position()).length() > draw_points_min_distance:
				line.add_point(get_global_mouse_position())
	
	if Input.is_action_just_pressed("Undo"):
		if line:
			if line.points.size() > 0:
				undo_action()

func undo_action():
	is_drawing = false
	var current_line = line_array[line_array.size() - 1]
	line_array.remove_at(line_array.size() - 1)
	current_line.queue_free()
	if line_array.size() > 0:
		line = line_array[line_array.size() - 1]
