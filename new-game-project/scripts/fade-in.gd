extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.y = -1000
	scale = Vector2(40,40)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	modulate.a -= delta
