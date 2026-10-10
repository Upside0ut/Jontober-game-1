extends CharacterBody2D

enum States {IDLE, HUNTING, ATTACKING, SCARED, DASHING}
var state

var rng = RandomNumberGenerator.new()

var player
var feinting = false
var previous_player_distance = 0
var stuck_too_long = false
var current_dash_point
var dash_counter = 0

var move_speed = 1000
var sprint_speed = 2000
var health = 100
var on_hit_depleted_health = 50

var standard_spray_time = 5
var standard_feint_time = 5

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
			previous_player_distance = find_player_distance()
			hunting()
		States.ATTACKING:
			attacking()
		States.SCARED:
			scared()
		States.DASHING:
			dash_counter += 1
			dashing()
	
	move_and_slide()
	
	if state == States.HUNTING and previous_player_distance <= find_player_distance():
		stuck_too_long = true
		changeState(States.IDLE)
		print("STUCK TOO LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOONG")
	else:
		stuck_too_long = false

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
	if (stuck_too_long):
		changeState(States.ATTACKING)
		return
	
	if (find_player_distance() > 1500):
		changeState(States.HUNTING)
		return
	
	changeState(States.ATTACKING)

func hunting():
	if (find_player_distance() > 1000):
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
	match decide_attack():
		0:
			changeState(States.IDLE)
		1:
			await dash()
			return
		2:
			await spray(standard_spray_time)
		3:
			await feint(standard_feint_time)
	
	close_openings()
	changeState(States.IDLE)

func decide_attack():
	if(find_player_distance() > 1000):
		if(clear_shot(player)):
			return [1, 1, 2].pick_random()
		else:
			return 1
	
	if(find_player_distance() > 600):
		if(clear_shot(player)):
			return [2, 2, 2, 1].pick_random()
		else:
			return [1, 1, 2].pick_random()
	
	if(clear_shot(player)):
		return [2, 3].pick_random()
	
	return [2, 3, 3, 3].pick_random()
	
	

func attacking():
	pass

func dash():
	print("dash")
	var dash_points = get_parent().get_node("DashCheckpoints").get_children()
	dash_points.shuffle()
	
	for dash_point in dash_points:
		if(clear_shot(dash_point)):
			current_dash_point = dash_point
			changeState(States.DASHING)
			break

func dashing():
	if(dash_counter > 500):
		dash_counter = 0
		changeState(States.IDLE)
		return
	
	velocity = global_position.direction_to(current_dash_point.global_position) * move_speed

func reached_dash_point():
	if (state == States.DASHING):
		changeState(States.IDLE)

func spray(time: float):
	create_opening(-1)
	$Timer.one_shot = true
	$Timer.start(time)
	while $Timer.time_left > 0:
		await shoot_bullet()
		print($Timer.time_left)
		await wait(1)
	$Timer.stop()

func shoot_bullet():
	var bulletScene = preload("res://scenes/bullet_boss_abstraction.tscn")
	var bullet = bulletScene.instantiate()
	add_sibling(bullet)
	
	bullet.global_position = $SplatterRing.get_nearest_global_ring_position_to(find_player_position(), true)
	bullet.shoot(find_player_direction())

func feint(time):
	create_opening(-1)
	#TODO play slight tell animation
	feinting = true
	$Timer.start(time)
	await $Timer.timeout
	feinting = false

func feint_success():
	#TODO play biting animation
	#damage is anyway cus spikes
	$Timer.stop()
	$Timer.timeout.emit()
	await wait(0.3)
	changeState(States.SCARED)

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

func clear_shot(object):
	var space_state = get_world_2d().direct_space_state
	
	var params = PhysicsRayQueryParameters2D.new()
	params.from = global_position
	params.to = object.global_position
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
