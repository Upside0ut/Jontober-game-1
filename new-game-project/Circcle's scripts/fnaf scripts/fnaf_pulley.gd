extends Sprite2D

@onready var child_area = get_child(0)

var pulldown_length := 200.0
var original_position := Vector2.ZERO
var minimum_position := 0.0
var alarm_on_height := 0.0
var rope_half_size := 0.0

var holding_rope := false

var alarm_state := false
signal alarm_on
signal alarm_off

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	child_area.input_event.connect(_on_input_event)
	minimum_position = global_position.y
	global_position.y -= pulldown_length
	original_position = global_position
	rope_half_size = texture.get_height()/2.0
	alarm_on_height = original_position.y + rope_half_size/3
	
	print(minimum_position)
	print(original_position)
	print(global_position.y)
	print(alarm_on_height)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	if holding_rope and global_position.y < minimum_position:
		global_position.y = clamp(
			lerp(
				global_position.y, 
				mouse_pos.y-rope_half_size, 
				delta*5),
				-INF,
				minimum_position)
	else:
		global_position.y = lerp(global_position.y, original_position.y, delta*5)
	
	if global_position.y > alarm_on_height:
		if not alarm_state:
			alarm_on.emit()
			alarm_state = true
	else:
		if alarm_state:
			alarm_off.emit()
			alarm_state = false

# connected input event
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click_interact"):
		print("holding rope")
		holding_rope = true

func _input(event: InputEvent) -> void:
	if event.is_action_released("click_interact") and holding_rope:
		print("not holding rope")
		holding_rope = false
