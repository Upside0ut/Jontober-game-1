extends Node2D

@export var art: Texture
@export_category("Particles - MAX 5!!!")
@export var shatter_particles: Array[Texture]
@onready var particles: Array[GPUParticles2D] = [$shatter_1, $shatter_2, $shatter_3, $shatter_4, $shatter_5]

func _ready() -> void:
	if art:
		$Sprite2D.texture = art
		for n in particles:
			n.process_material.emission_box_extents = Vector3($Sprite2D.get_rect().size.x, $Sprite2D.get_rect().size.y, 1.0)
	if shatter_particles:
		match shatter_particles.size():
			1:
				$shatter_1.texture = shatter_particles[0]
			2:
				$shatter_1.texture =  shatter_particles[0]
				$shatter_2.texture =  shatter_particles[1]
			3:
				$shatter_1.texture =  shatter_particles[0]
				$shatter_2.texture =  shatter_particles[1]
				$shatter_3.texture =  shatter_particles[2]
			4:
				$shatter_1.texture =  shatter_particles[0]
				$shatter_2.texture =  shatter_particles[1]
				$shatter_3.texture =  shatter_particles[2]
				$shatter_4.texture =  shatter_particles[3]
			5:
				$shatter_1.texture =  shatter_particles[0]
				$shatter_2.texture =  shatter_particles[1]
				$shatter_3.texture =  shatter_particles[2]
				$shatter_4.texture =  shatter_particles[3]
				$shatter_5.texture =  shatter_particles[4]

func _on_destruct_area_area_entered(area: Area2D) -> void:
	if area.name == "explosion_area":
		$Sprite2D.visible = false
		for n in particles:
			n.emitting = true
