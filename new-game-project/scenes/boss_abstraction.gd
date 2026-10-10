extends CharacterBody2D

enum States {IDLE, HUNTING, ATTACKING, SCARED}
var state

var rng = RandomNumberGenerator.new()

var player

var move_speed = 1000
var sprint_speed = 1700
var health = 100
var on_hit_depleted_health = 50

var standard_spray_time = 5

func changeState(newState: States):
	state = newState
	
	match state:
		States.IDLE:
			idle()
		States.HUNTING:
			pass
		States.SCARED:
			pass
		States.ATTACKING:
			attack()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_node("Player")
	
	await wait(3)
	get_parent().get_node("BossMusic").play()
	changeState(States.IDLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if health < 1:
		die()
	
	match state:
		States.IDLE:
			pass
		States.HUNTING:
			hunting()
		States.ATTACKING:
			attacking()
		States.SCARED:
			scared()

	move_and_slide()

func depleteHealth():
	print("Damaged: ")
	print(on_hit_depleted_health)
	health -= on_hit_depleted_health
	#play damage anymation
	$Timer.stop()
	$Timer.timeout.emit()
	await wait(0.3)
	$SplatterRing/spikes.set_deferred("monitorable", true)
	changeState(States.SCARED)

func die():
	print("DEAD")
	queue_free()

func idle():
	if (find_player_position() > 3000):
		changeState(States.HUNTING)
		return
	
	if (clear_shot()):
		changeState(States.ATTACKING)
		return
	

func hunting():
	if (find_player_distance() > 1500):
		move_toward_player(move_speed)
	else:
		print("hunt to atk")
		changeState(States.ATTACKING)

func scared():
	if (find_player_distance() < 500):
		move_away_from_player(sprint_speed)
	else:
		print("scared to idle")
		changeState(States.IDLE)

func attack():
	match 2:
		0:
			changeState(States.IDLE)
		1:
			await dash()
		2:
			await spray(standard_spray_time)
		3:
			await feint()
	
	close_openings()

func decide_attack():
	if(find_player_distance() > 2000 and !clear_shot()):
		if(clear_shot()):
			return [1, 1, 2].pick_random()
		else:
			return 1
	
	if(find_player_distance() > 700):
		if(clear_shot()):
			return [2, 2, 2, 1].pick_random()
		else:
			return 1
	
	if(clear_shot()):
		return [2, 2, 2, 1].pick_random()
	
	
	

func attacking():
	pass

func dash():
	print("dash")

func spray(time: float):
	create_opening(-1)
	$Timer.start(time)
	while $Timer.time_left > 0:
		await shoot_bullet()
		print("shot")
		await wait(1)

func shoot_bullet():
	var bulletScene = preload("res://scenes/bullet_boss_abstraction.tscn")
	var bullet = bulletScene.instantiate()
	add_sibling(bullet)
	
	
	bullet.global_position = $SplatterRing.get_nearest_global_ring_position_to(find_player_position(), true)
	bullet.shoot(find_player_direction())

func feint():
	print("feint")

func move_toward_player(speed: int):
	velocity = find_player_direction() * speed

func move_away_from_player(speed: int):
	velocity = -find_player_direction() * speed

func get_current_opening():
	$SplatterRing.get_current_opening()

func create_opening(i: int):
	if(-1 < i and i < 8):
		$SplatterRing.create_opening(i)
	else:
		$SplatterRing.create_random_opening()

func close_openings():
	$SplatterRing.close_openings()

func clear_shot():
	var space_state = get_world_2d().direct_space_state
	
	var params = PhysicsRayQueryParameters2D.new()
	params.from = global_position
	params.to = player.global_position
	params.exclude = [] 
	
	
	var result = space_state.intersect_ray(params)
	
	if (result):
		return true
	return false

func find_player_direction():
	return global_position.direction_to(get_parent().get_node("Player").global_position)

func find_player_distance():
	return global_position.distance_to(get_parent().get_node("Player").global_position)

func find_player_position():
	return get_parent().get_node("Player").global_position

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
