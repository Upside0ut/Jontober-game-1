extends StaticBody2D

@onready var peg_hit_sfx: AudioStreamPlayer = $peg_sound
@export var animation_player : AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(peg_hit_sfx != null, "Plinko Peg didn't find the Peg Hit SFX!")
	$peg_sound.pitch_scale = randf_range(.9, 1.1)

func boing():
	animation_player.play("boing")
	peg_hit_sfx.play()
