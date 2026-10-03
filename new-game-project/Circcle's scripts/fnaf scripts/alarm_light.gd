extends Sprite2D

@export var root_node : Node2D
@onready var lights : Node2D = get_child(0)

@export var rotation_speed : float = 360.0
#change to textureprogressbar later
@export var rage_bar : ProgressBar
var rage_locked := false

const MAX_RAGE_TIME := 45.0
var current_rage := 0.0 # in seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rage_bar.value_changed.connect(_on_value_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if root_node.alarm_turned_on and !rage_locked:
		lights.visible = true
		modulate.r = 1.0
		
		lights.rotation_degrees += delta*rotation_speed
		rage_bar.value += delta*(100.0/5.0)

	else:
		lights.visible = false
		lights.rotation_degrees = 0
		# 50 is the original color of the alarm, im lazy so im hardcoding
		modulate.r = 50.0 / 255.0
		
		if !rage_locked:
			rage_bar.value -= delta*(100.0/100.0)

func _on_value_changed(value):
	if value >= 100:
		rage_locked = true
		print("uh oh!")
		#something wicked this way comes or wtv ultrakill
