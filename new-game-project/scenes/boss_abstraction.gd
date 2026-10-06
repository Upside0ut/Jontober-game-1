extends CharacterBody2D

enum States {IDLE, HUNTING, ATTACKING}
var state

var rng = RandomNumberGenerator.new()

var move_speed = 1000

func changeState(newState):
	state = newState
	
	match state:
		States.IDLE:
			idle()
		States.HUNTING:
			pass
		States.ATTACKING:
			attack()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await wait(3)
	get_parent().get_node("BossMusic").play()
	changeState(States.IDLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO

	match state:
		States.HUNTING:
			hunting()
		States.ATTACKING:
			attacking()

	move_and_slide()

func idle():
	await wait(1)
	changeState(States.HUNTING)

func hunting():
	if (find_player_distance() > 500):
		move_toward_player()
	else:
		changeState(States.ATTACKING)

func attack():
	match 2:
		0:
			changeState(States.IDLE)
		1:
			dash()
		2:
			shoot()
		3:
			feint()
	
	close_opening()
	changeState(States.IDLE)

func decide_attack():
	return rng.randi_range(0, 3) #make like a bunch of checks (e.g. distance, health)

func attacking():
	pass

func dash():
	print("dash")

func shoot():
	var bulletScene = preload("res://scenes/bullet_boss_abstraction.tscn")
	var bullet = bulletScene.instantiate()
	add_child(bullet)
	
	bullet.position = get_nearest_ring_position_to(find_player_position())
	bullet.shoot(find_player_direction())
	
	create_opening(-1)
	print("shoot")
	await wait(3)

func feint():
	print("feint")

func move_toward_player():
	velocity = find_player_direction() * move_speed


func get_nearest_ring_position_to(target_position: Vector2):
	return get_node("SplatterRing").get_nearest_ring_position_to(target_position)

func get_random_ring_position():
	return get_node("SplatterRing").get_random_ring_position()

func create_opening(i):
	if(-1 < i and i < 9):
		get_node("SplatterRing").create_opening(i)
	else:
		get_node("SplatterRing").create_random_opening()

func close_opening():
	get_node("SplatterRing").close_opening()

func find_player_direction():
	return global_position.direction_to(get_parent().get_node("Player").global_position)

func find_player_distance():
	return global_position.distance_to(get_parent().get_node("Player").global_position)

func find_player_position():
	return get_parent().get_node("Player").global_position

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
