extends CharacterBody2D

var move_speed = 700
var following = false
var target

func _physics_process(delta: float) -> void:
	if(following and target != null):
		shoot(find_direction_to(target))
	
	move_and_slide()

func shoot(direction: Vector2):
	velocity = direction * move_speed

func follow(target: Node2D, time: float):
	self.target = target
	following = true
	await wait(time)
	following = false


func find_direction_to(object: Node2D):
	return global_position.direction_to(object.global_position)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
