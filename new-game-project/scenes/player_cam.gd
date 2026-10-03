extends Camera2D

const BASE_WIDTH := 1152.0
const PANNING_SPEED := 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_update_zoom)
	_update_zoom()

func _update_zoom() -> void:
	
	#because the project is on aspect: expand instead of aspect: keep, the shorter sides fills the screen to the max,
	#which broke how wide the camera was and how much you could pan and stuff this adjusts the camera's zoom
	#to counteract that manually
	var camzoom = get_viewport_rect().size.x/BASE_WIDTH*0.5 # 0.5 is half zoom of whatever's calculated, like how it is in the node tree
	zoom = Vector2(camzoom, camzoom)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var viewport_left_third = get_viewport_rect().size.x/3
	var viewport_right_third = get_viewport_rect().size.x/3*2
	var mouse_pos = get_viewport().get_mouse_position()
	
	var half_width = get_viewport_rect().size.x / zoom.x / 2.0
	var min_x = limit_left + half_width
	var max_x = limit_right - half_width
	
	if mouse_pos.x > viewport_right_third:
		position.x = clamp(move_toward(position.x, limit_right, delta*PANNING_SPEED),min_x,max_x)
	elif mouse_pos.x < viewport_left_third:
		position.x = clamp(move_toward(position.x, limit_left, delta*PANNING_SPEED),min_x,max_x)
	else:
		position.x = clamp(move_toward(position.x, 0.0, delta*PANNING_SPEED),min_x,max_x)
