extends CanvasLayer

@onready var confettis: Array[GPUParticles2D] = [$confetti, $confetti2, $confetti3, $confetti4, $confetti5]

# confetti time
func _ready() -> void:
	for n in confettis:
		n.emitting = true
	await get_tree().create_timer(2.5).timeout
	$song.play()


func next_level() -> void:
	if(Global.current_level.is_b_route):
		Global.switch_back_from_b_route()
	else:
		Global.switch_to_next_level()
