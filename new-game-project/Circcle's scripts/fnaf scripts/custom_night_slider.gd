extends HBoxContainer

@onready var left = $left
@onready var diff_num = $diff_num
@onready var right = $right

var current_diff := 1
var hold_time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	left.button_down.connect(_on_left)
	right.button_down.connect(_on_right)
	update_diff_tooltip()

func _on_left():
	current_diff -= 1
	if current_diff < 0:
		current_diff = 20
	 
	update_diff_tooltip()
	hold_time = 0.0

func _on_right():
	current_diff += 1
	if current_diff > 20:
		current_diff = 0
	
	update_diff_tooltip()
	hold_time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hold_time += delta
	if hold_time >= 0.15:
		if left.is_pressed():
			_on_left()
		elif right.is_pressed():
			_on_right()
	
	diff_num.text = "%02d" % current_diff

func update_diff_tooltip() -> void:
	var stats: Dictionary = NightData.get_stats(current_diff) if get_parent().name == "Agnese" else NightData.get_stats(current_diff, 0.3) 
	
	diff_num.tooltip_text = (
		"AI Level: %d
		\nMove Interval: %.1f s
		\nAttack Time: %.1f s
		\nTime to Repel: %.1f s" % [stats["ai_level"], stats["move_interval"], stats["attack_time"], stats["time_to_repel"]]
	)
