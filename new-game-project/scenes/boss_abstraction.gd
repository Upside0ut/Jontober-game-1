extends CharacterBody2D

enum States {IDLE, HUNTING, ATTACKING, SCARED, DASHING, DEAD}
var state

var rng = RandomNumberGenerator.new()

var player
var center
var feinting = false
var previous_player_distance = 0
var stuck_too_long = false
var current_dash_point
var dash_counter = 0
var on_screen = false
var attacking_while_not_on_screen_counter = 0
var bar_fully_loaded = false
var rotating = false
var recently_hit = false
var moving_to_center = false
var mid_attack = false
var done_hunting = false
var munching = false
var middle_opening_name = null
var last_decided_atk = 0
var dead = false

var move_speed = 1000
var sprint_speed = 2400
var health = 100
var on_hit_depleted_health = 20

var hunt_distance = rng.randi_range(500, 1500)
var attacking_while_not_on_screen_threshhold = 60 * 3

var standard_spray_time = 7
var standard_bullet_time = 0.5
var standard_munch_time = 9
var standard_feint_time = 5
var standard_missile_atk_time = 10

var feint_cooldown_time = 20

func changeState(newState: States):
	if dead:
		return
	
	state = newState
	
	match state:
		States.IDLE:
			await idle()
		States.HUNTING:
			hunt_distance = rng.randi_range(500, 1300) - rng.randi_range(0, 100) #added like an offset i think is smoother now
			print("Hunt Distance:")
			print(hunt_distance)
		States.SCARED:
			pass
		States.ATTACKING:
			if (!mid_attack):
				await attack()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_node("Player")
	center = get_parent().get_node("CenterPoint")
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
	if health < 1 and !dead:
		die()
	
	if dead and state != States.DEAD:
		state = States.DEAD
	
	if !dead:
		if (rotating):
			rotate(0.01)
		
		if (munching):
			rotate_in_player_direction(delta)
		
		velocity = Vector2.ZERO
		
		if(bar_fully_loaded):
			$CanvasLayer/BossBar.value = health
		
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
		
		move_and_slide()

func rotate_in_player_direction(delta):
	if (dead):
		return
	
	var teeth_direction = global_position.direction_to($Body/Teeth.global_position)
	var rotation_speed = 0.007
	
	if (teeth_direction.angle() < find_player_direction().angle()):
		rotate(rotation_speed)
	elif (find_player_direction().angle() < teeth_direction.angle()):
		rotate(-rotation_speed)

func depleteHealth():
	print("Damaged: ")
	print(on_hit_depleted_health)
	health -= on_hit_depleted_health
	
	$AttackTimer.stop()
	$AttackTimer.timeout.emit()
	
	$AnimationPlayer.play("shake")
	player.process_mode = Node.PROCESS_MODE_DISABLED
	$Bossdmgsound.play()
	await wait(0.3)
	$AnimationPlayer.stop()
	player.process_mode = Node.PROCESS_MODE_INHERIT
	
	if health < 1 and get_node_or_null("Body/Head/teeth_area") != null:
		$Body/Head/teeth_area.queue_free()
		return
	close_openings()
	if get_node_or_null("SplatterRing/spikes") != null:
		$SplatterRing/spikes.set_deferred("monitorable", true)
		$SplatterRing/spikes.set_deferred("monitoring", true)
	changeState(States.SCARED)

func die():
	$Body.queue_free()
	$SplatterRing.queue_free()
	$ExplosionCompression.play()
	$Explosion.play()
	dead = true
	print("DEAD")
	
	get_parent().get_node("BossMusic").stop()
	player.process_mode = Node.PROCESS_MODE_INHERIT
	
	$fullParticles.show()
	await wait(0.1)
	get_parent().get_node("ground tilemap").queue_free()
	await wait(2)
	get_parent().get_node("BottomSplatterwall").queue_free()
	queue_free()

func idle():
	if (dead):
		return
	
	$AnimationPlayer.play("RESET", 0.3)
	
	if (done_hunting):
		done_hunting = false
		changeState(States.ATTACKING)
	
	if (find_player_distance() > 1500 or !on_screen):
		changeState(States.HUNTING)
		return
	
	changeState(States.ATTACKING)

func hunting():
	if (dead):
		return
	
	if (!on_screen):
		move_toward_player(move_speed)
	elif (find_player_distance() > hunt_distance):
		move_toward_player(move_speed)
	else:
		done_hunting = true
		changeState(States.IDLE)

func scared():
	if (dead):
		return
	
	if (find_player_distance() < 1500):
		move_away_from_player(sprint_speed)
	else:
		print("scared to idle")
		recently_hit = true
		changeState(States.IDLE)

func attack():
	if (dead):
		return
	
	mid_attack = true
	var decided_atk = decide_attack()
	
	var retrys = 0
	while(decided_atk == last_decided_atk and retrys <= 3):
		retrys += 1
		decided_atk = decide_attack()
	
	while (($FeintCooldown.time_left > 0) and decided_atk == 3):
		decided_atk = decide_attack()
	
	last_decided_atk = decided_atk
	
	print("Decided Attack: ")
	print(decided_atk)
	
	match 1:
		0:
			changeState(States.IDLE)
		1:
			await munch(standard_munch_time)
		2:
			await spray(standard_spray_time, standard_bullet_time)
		3:
			await feint(standard_feint_time)
		4:
			await missile_attack(standard_missile_atk_time)
		5:
			await center_attack()
	
	close_openings()
	
	mid_attack = false
	changeState(States.IDLE)

func decide_attack():
	if (dead):
		return
	#if(recently_hit and randi_range(1, 10) > 2):
		#print("decided 5")
		#recently_hit = false
		#return 5
	recently_hit = false
	
	if(find_player_distance() > 1000):
		if(clear_shot(player)):
			return [1, 2, 2, 4, 4, 4].pick_random()
		else:
			return [2, 2, 2, 4, 4, 4].pick_random()
	
	if(find_player_distance() > 600):
		if(clear_shot(player)):
			if (health > 50):
				return [1, 1, 2, 2, 2, 4, 4].pick_random()
			else:
				return [3, 1, 1, 2, 2, 2, 4, 4].pick_random()
		else:
			return [2, 2, 2, 4, 4].pick_random()
	
	if (health > 50):
		if(clear_shot(player)):
			return [1, 1, 1, 1, 2, 2, 2].pick_random()
		else:
			return [1, 1, 2, 2].pick_random()
	else:
		if(clear_shot(player)):
			return [1, 1, 1, 1, 1, 3, 3, 3, 2, 2].pick_random()
		else:
			return [1, 1, 3, 2, 2].pick_random()

func attacking():
	if (dead):
		return
	
	if (moving_to_center):
		move_toward_center(move_speed)
	
	if(!on_screen):
		attacking_while_not_on_screen_counter += 1
	
	if(attacking_while_not_on_screen_counter > attacking_while_not_on_screen_threshhold):
		$AttackTimer.stop()
		$AttackTimer.timeout.emit()

func spray(total_time: float, time_between_bullets):
	if (dead):
		return
	
	create_opening(-1)
	$AttackTimer.one_shot = true
	$AttackTimer.start(total_time)
	
	rotating = true
	
	while $AttackTimer.time_left > 0:
		await shoot_bullet(time_between_bullets)
	
	rotating = false
	$AttackTimer.stop()

func shoot_bullet(time: float):
	if (dead):
		return
	
	var bulletScene = preload("res://scenes/bullet_boss_abstraction.tscn")
	var bullet = bulletScene.instantiate()
	add_sibling(bullet)
	
	bullet.get_node("AnimationPlayer").play("windUp")
	bullet.global_position = $SplatterRing.get_random_global_ring_position(true)
	
	await wait(time)
	$BossShootSplatter.play()
	bullet.shoot(global_position.direction_to(bullet.global_position))

func missile_attack(total_time):
	if (dead):
		return
	
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
	if (dead):
		return
	
	var missileScene = preload("res://scenes/missile_boss_abstraction.tscn")
	var missile = missileScene.instantiate()
	add_sibling(missile)
	
	missile.global_position = $SplatterRing.get_current_opening_position()
	missile.shoot(find_player_direction())

func shoot_follow_missile():
	if (dead):
		return
	
	var missileScene = preload("res://scenes/missile_boss_abstraction.tscn")
	var missile = missileScene.instantiate()
	add_sibling(missile)
	
	missile.global_position = $SplatterRing.get_current_opening_position()
	missile.follow(player, 5)

func feint(time):
	if (dead):
		return
	
	create_player_direction_opening()
	#TODO play slight tell animation #nvm i think
	feinting = true
	rotating = true
	$AttackTimer.one_shot = true
	$AttackTimer.start(time)
	await $AttackTimer.timeout
	
	$FeintCooldown.one_shot = true
	$FeintCooldown.start(feint_cooldown_time)
	feinting = false
	rotating = false

func feint_success():
	if (dead):
		return
	
	rotating = false
	play_feint_move_animation(false)
	await $AnimationPlayer.animation_finished
	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	$Body/Teeth.play("bite")
	await $Body/Teeth.animation_finished
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.die() #mb if this is supposed to be private or sm but it really looks ugly otherwise sooory
	await wait(0.2)
	$Body/Teeth.play_backwards("bite")
	$BossBurp.play()
	await $BossBurp.finished

func play_feint_move_animation(backwards: bool, opening:String = $SplatterRing.get_current_opening().name):
	if (dead):
		return
	
	if(!backwards):
		match opening:
			"OpeningTop": $AnimationPlayer.play("feint_top")
			"OpeningTopRight": $AnimationPlayer.play("feint_top_right")
			"OpeningRight": $AnimationPlayer.play("feint_right")
			"OpeningBottomRight": $AnimationPlayer.play("feint_bottom_right")
			"OpeningBottom": $AnimationPlayer.play("feint_bottom")
			"OpeningBottomLeft": $AnimationPlayer.play("feint_bottom_left")
			"OpeningLeft": $AnimationPlayer.play("feint_left")
			"OpeningTopLeft": $AnimationPlayer.play("feint_top_left")
	else:
		match opening:
			"OpeningTop": $AnimationPlayer.play_backwards("feint_top")
			"OpeningTopRight": $AnimationPlayer.play_backwards("feint_top_right")
			"OpeningRight": $AnimationPlayer.play_backwards("feint_right")
			"OpeningBottomRight": $AnimationPlayer.play_backwards("feint_bottom_right")
			"OpeningBottom": $AnimationPlayer.play_backwards("feint_bottom")
			"OpeningBottomLeft": $AnimationPlayer.play_backwards("feint_bottom_left")
			"OpeningLeft": $AnimationPlayer.play_backwards("feint_left")
			"OpeningTopLeft": $AnimationPlayer.play_backwards("feint_top_left")

func munch(time):
	if (dead):
		return
	
	munching = true
	create_tripple_player_direction_opening()
	middle_opening_name = $SplatterRing.get_nearest_opening_to(player.position, false).name
	play_feint_move_animation(false, middle_opening_name)
	$AttackTimer.one_shot = true
	$AttackTimer.start(time)
	await $AttackTimer.timeout
	munching = false

func munch_success():
	if (dead):
		return
	
	await wait(0.15)
	player.process_mode = Node.PROCESS_MODE_DISABLED
	$Body/Teeth.play("bite")
	await wait(0.05)
	player.die()
	await $Body/Teeth.animation_finished
	await wait(0.2)
	player.process_mode = Node.PROCESS_MODE_INHERIT
	print("MIGHT CRASH RN, IF NAME NULL CUS I FUCKED UP")
	$Body/Teeth.play_backwards("bite")
	$BossBurp.play()
	await $BossBurp.finished

func center_attack():
	if (dead):
		return
	
	moving_to_center = true
	await center.boss_entered_signal
	moving_to_center = false
	
	$AnimationPlayer.play("shake")
	await move_walls()
	$AnimationPlayer.stop()
	
	print("reached center")

func move_walls():
	await wait(3)

func move_toward_center(speed: int):
	velocity = find_center_direction() * speed

func find_center_direction():
	if (dead):
		return
	
	return global_position.direction_to(center.global_position)

func move_toward_player(speed: int):
	if (dead):
		return
	
	velocity = find_player_direction() * speed

func move_away_from_player(speed: int):
	if (dead):
		return
	
	velocity = -find_player_direction() * speed

func get_current_opening():
	if (dead):
		return
	
	if get_node_or_null("SplatterRing") != null:$SplatterRing.get_current_opening()

func create_opening(i: int):
	if (dead):
		return
	
	if(-1 < i and i < 8):
		if get_node_or_null("SplatterRing") != null:$SplatterRing.create_opening(i)
	else:
		if get_node_or_null("SplatterRing") != null:$SplatterRing.create_random_opening()

func create_player_direction_opening():
	if (dead):
		return
	
	if get_node_or_null("SplatterRing") != null:$SplatterRing.create_opening_close_to(player.global_position)

func create_tripple_player_direction_opening():
	if (dead):
		return
	
	if get_node_or_null("SplatterRing") != null:$SplatterRing.create_tripple_opening_close_to(player.global_position)

func close_openings():
	if (dead):
		return
	
	if get_node_or_null("SplatterRing") != null:$SplatterRing.close_openings()

func clear_shot(object):
	if (dead):
		return
	
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
	if (dead):
		return
	
	return global_position.direction_to(player.global_position)

func find_player_distance():
	if (dead):
		return
	
	return global_position.distance_to(player.global_position)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _on_screen_entered() -> void:
	if (dead):
		return
	
	on_screen = true

func _on_screen_exited() -> void:
	if (dead):
		return
	
	on_screen = false

func _on_teeth_area_body_entered(body: Node2D) -> void:
	if (dead):
		return
	
	if(body == player and munching):
		munching = false
		$SplatterRing.queue_free()
		munch_success()
		$Body/Head/teeth_area.queue_free()
