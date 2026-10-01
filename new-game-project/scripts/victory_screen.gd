extends CanvasLayer

@onready var confettis: Array[GPUParticles2D] = [$confetti, $confetti2, $confetti3, $confetti4, $confetti5]

# confetti time
func _ready() -> void:
	for n in confettis:
		n.emitting = true
	await get_tree().create_timer(2.5).timeout
	$song.play()


func next_level() -> void:
	get_tree().change_scene_to_file(Global.levels[Global.level])
