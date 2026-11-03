extends CanvasLayer

@onready var confettis: Array[GPUParticles2D] = [$confetti, $confetti2, $confetti3, $confetti4, $confetti5]

# confetti time
func _ready() -> void:
	for n in confettis:
		n.emitting = true
	await get_tree().create_timer(2.5).timeout
	$song.play()


func next_level() -> void:
	assert(Global.current_level != null, "Global.current_level is null inside Victory Screen, if you used 'Run Current Scene' to playtest, this is why. (Circcle)")
		
	if(Global.current_level.is_b_route):
		Global.switch_back_from_b_route()
	else:
		print("asd")
		Global.switch_to_next_level()
