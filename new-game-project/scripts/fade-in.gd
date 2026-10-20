extends ColorRect

@export var fade_out_by_default := true
## Circcle: I added this so u can turn it off in the editor and not have to worry about turning it back on.
@export var force_appear_in_game := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if force_appear_in_game: visible = true
	
	position.y = -1000
	scale = Vector2(40,40)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade_out_by_default:
		modulate.a = clamp(modulate.a-delta,0.0,1.0)
