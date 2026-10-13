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
var on_screen = false
var bar_fully_loaded = false
var rotating = false

var move_speed = 1000
var sprint_speed = 2400
var health = 100
var on_hit_depleted_health = 25

var standard_spray_time = 10
var standard_bullet_time = 0.5
var standard_feint_time = 5
var standard_missle_atk_time = 7

var feint_cooldown_time = 20

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
	$CanvasLayer/BossBar.hide()
	$CanvasLayer/BossBar.value = 0
	
	await wait(3)
	
	get_parent().get_node("BossMusic").play()
	changeState(States.IDLE)
	$CanvasLayer/BossBar.show()
	
	while($CanvasLayer/BossBar.value != 100):
		$CanvasLayer/BossBar.value += 2
		await wait(0.01)
	bar_fully_loaded = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (rotating):
		rotate(0.01)
	
	velocity = Vector2.ZERO
	
	if(bar_fully_loaded):
		$CanvasLayer/BossBar.value = health
	
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

func depleteHealth():
	print("Damaged: ")
	print(on_hit_depleted_health)
	health -= on_hit_depleted_health
	#play damage anymation
	$AttackTimer.stop()
	$AttackTimer.timeout.emit()
	
	$AnimationPlayer.play("shake")
	player.process_mode = Node.PROCESS_MODE_DISABLED
	$Bossdmgsound.play()
	await wait(0.3)
	$AnimationPlayer.stop()
	player.process_mode = Node.PROCESS_MODE_INHERIT
	
	close_openings()
	$SplatterRing/spikes.set_deferred("monitorable", true)
	$SplatterRing/spikes.set_deferred("monitoring", true)
	changeState(States.SCARED)

func die():
	print("DEAD")
	queue_free()

func idle():
	if (stuck_too_long):
		changeState(States.ATTACKING)
		return
	
	if (find_player_distance() > 1500 or !on_screen):
		changeState(States.HUNTING)
		return
	
	changeState(States.ATTACKING)

func hunting():
	if (find_player_distance() > 600):
		move_toward_player(move_speed)
	else:
		print("hunt to atk")
		changeState(States.ATTACKING)

func scared():
	if (find_player_distance() < 1500):
		move_away_from_player(sprint_speed)
	else:
		print("scared to idle")
		changeState(States.IDLE)

func attack():
	var decided_atk = decide_attack()
	
	while $FeintCooldown.time_left > 0 and decided_atk == 3:
		decided_atk = decide_attack()
	
	match decided_atk:
		0:
			changeState(States.IDLE)
		1:
			await dash()
			return
		2:
			await spray(standard_spray_time, standard_bullet_time)
		3:
			await feint(standard_feint_time)
		4:
			await missile_attack(standard_missle_atk_time)
	
	close_openings()
	
	if(state != States.SCARED):
		changeState(States.IDLE)

func decide_attack():
	if(find_player_distance() > 1000):
		if(clear_shot(player)):
			return [1, 2, 4, 4].pick_random()
		else:
			return [1, 1, 1, 1, 4].pick_random()
	
	if(find_player_distance() > 600):
		if(clear_shot(player)):
			return [1, 2, 4,  1, 2, 4,  2, 4,  3].pick_random()
		else:
			return [2, 2, 2,  4, 4, 4,  1].pick_random()
	
	if(clear_shot(player)):
		return [2, 2, 4, 3, 3].pick_random()
	
	return [2, 2, 2, 2, 4, 4, 4, 3].pick_random()

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
	
	if(!on_screen):
		changeState(States.IDLE)
		return
	
	velocity = global_position.direction_to(current_dash_point.global_position) * move_speed

func reached_dash_point():
	if (state == States.DASHING):
		changeState(States.IDLE)

func spray(total_time: float, time_between_bullets):
	create_opening(-1)
	$AttackTimer.one_shot = true
	$AttackTimer.start(total_time)
	
	rotating = true
	
	var spray_while_not_on_screen_conuter = 0
	while $AttackTimer.time_left > 0:
		if (!on_screen):
			if (spray_while_not_on_screen_conuter > 5):
				$AttackTimer.stop()
				$AttackTimer.timeout.emit()
				break
			spray_while_not_on_screen_conuter += 1
		
		await shoot_bullet(time_between_bullets)
	
	rotating = false
	$AttackTimer.stop()

func shoot_bullet(time: float):
	var bulletScene = preload("res://scenes/bullet_boss_abstraction.tscn")
	var bullet = bulletScene.instantiate()
	add_sibling(bullet)
	
	bullet.get_node("AnimationPlayer").play("windUp")
	bullet.global_position = $SplatterRing.get_random_global_ring_position(true)
	
	await wait(time)
	$BossShootSplatter.play()
	bullet.shoot(global_position.direction_to(bullet.global_position))

func missile_attack(total_time):
	await wait(0.5)
	create_player_direction_opening()
	$AttackTimer.one_shot = true
	$AttackTimer.start(total_time)
	rotating = true
	
	if (health > 50):
		shoot_normal_missile()
	else:
		shoot_follow_missile()
	
	await wait(total_time)
	rotating = false
	$AttackTimer.stop()

func shoot_normal_missile():
	var missileScene = preload("res://scenes/missile_boss_abstraction.tscn")
	var missile = missileScene.instantiate()
	add_sibling(missile)
	
	missile.global_position = $SplatterRing.get_current_opening_position()
	missile.shoot(find_player_direction())

func shoot_follow_missile():
	var missileScene = preload("res://scenes/missile_boss_abstraction.tscn")
	var missile = missileScene.instantiate()
	add_sibling(missile)
	
	missile.global_position = $SplatterRing.get_current_opening_position()
	missile.follow(player, 5)

func feint(time):
	create_player_direction_opening()
	#TODO play slight tell animation
	feinting = true
	rotating = true
	$AttackTimer.start(time)
	await $AttackTimer.timeout
	
	$FeintCooldown.one_shot = true
	$FeintCooldown.start(feint_cooldown_time)
	feinting = false
	rotating = false

func feint_success():
	rotating = false
	play_feint_move_animation(false)
	await $AnimationPlayer.animation_finished
	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	$Body/Teeth.play("bite")
	await $Body/Teeth.animation_finished
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.die()#mb if this is supposed to be private or sm but it really looks ugly otherwise sooory
	await wait(0.2)
	play_feint_move_animation(true)
	$Body/Teeth.play_backwards("bite")
	$BossBurp.play()
	await $BossBurp.finished

func play_feint_move_animation(backwards: bool):
	if(!backwards):
		match $SplatterRing.get_current_opening().name:
			"OpeningTop": $AnimationPlayer.play("feint_top")
			"OpeningTopRight": $AnimationPlayer.play("feint_top_right")
			"OpeningRight": $AnimationPlayer.play("feint_right")
			"OpeningBottomRight": $AnimationPlayer.play("feint_bottom_right")
			"OpeningBottom": $AnimationPlayer.play("feint_bottom")
			"OpeningBottomLeft": $AnimationPlayer.play("feint_bottom_left")
			"OpeningLeft": $AnimationPlayer.play("feint_left")
			"OpeningTopLeft": $AnimationPlayer.play("feint_top_left")
	else:
		match $SplatterRing.get_current_opening().name:
			"OpeningTop": $AnimationPlayer.play_backwards("feint_top")
			"OpeningTopRight": $AnimationPlayer.play_backwards("feint_top_right")
			"OpeningRight": $AnimationPlayer.play_backwards("feint_right")
			"OpeningBottomRight": $AnimationPlayer.play_backwards("feint_bottom_right")
			"OpeningBottom": $AnimationPlayer.play_backwards("feint_bottom")
			"OpeningBottomLeft": $AnimationPlayer.play_backwards("feint_bottom_left")
			"OpeningLeft": $AnimationPlayer.play_backwards("feint_left")
			"OpeningTopLeft": $AnimationPlayer.play_backwards("feint_top_left")

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

func create_player_direction_opening():
	$SplatterRing.create_opening_close_to(player.global_position)

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
	return global_position.direction_to(player.global_position)

func find_player_distance():
	return global_position.distance_to(player.global_position)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _on_screen_entered() -> void:
	on_screen = true

func _on_screen_exited() -> void:
	on_screen = false
