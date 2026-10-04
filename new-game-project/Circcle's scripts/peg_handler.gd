extends StaticBody2D

@export_group("Normal Gameplay")
@onready var peg_hit_sfx: AudioStreamPlayer = $peg_sound
@export var animation_player : AnimationPlayer

@export_group("FNAF-only Gameplay")
# Fnaf version checks, don't change!
@onready var colshape : CollisionShape2D = $CollisionShape2D
@onready var peg_sprite : CanvasItem = $"plinko peg"
@onready var error_sfx : AudioStreamPlayer = $"error_sound"

var broken := false

signal peg_clicked(peg)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(peg_hit_sfx != null, "Plinko Peg didn't find the Peg Hit SFX!")
	peg_hit_sfx.pitch_scale = randf_range(.9, 1.1)
	
	# Fnaf version checks, don't change!
	if owner and "fnaf_ver" in owner and owner.fnaf_ver == true:
		input_event.connect(_on_click_disable)
		add_to_group("pegs")

func boing():
	animation_player.play("boing")
	peg_hit_sfx.play()

#region FNAF_stuff
func _on_click_disable(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click_interact"):
		print(get_tree().current_scene.error_chance)
		if broken: 
			error_sfx.pitch_scale = randf_range(.9, 1.1)
			error_sfx.play()
			return
		
		# chance to break and not turn off
		if "error_chance" in get_tree().current_scene and randf() < get_tree().current_scene.error_chance:
			peg_sprite.material.set_shader_parameter("enabled", true)
			broken = true
			error_sfx.pitch_scale = randf_range(.9, 1.1)
			error_sfx.play()
			set_disabled(false)
			print("Peg error: ", self.name)
			return
		
		peg_clicked.emit(self)
		print("Disabled peg: ", self.name)

func set_disabled(value: bool):
	colshape.set_deferred("disabled", value)
	peg_sprite.modulate.a = 0.25 if value else 1.0   # low opacity when off
#endregion
