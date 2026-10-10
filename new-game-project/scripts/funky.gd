extends Control


var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/FUNKYlabel.hide()
	$FUNKYTextureRect.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_pressed("FUNKY_F") and
		Input.is_action_pressed("FUNKY_U") and
		Input.is_action_pressed("FUNKY_N") and
		Input.is_action_pressed("FUNKY_K") and
		Input.is_action_pressed("FUNKY_Y")):
		$Parallax2D/AnimationPlayer.speed_scale += 1
		$Parallax2D/AnimatedSprite2D.speed_scale += 1
		
		$MarginContainer/FUNKYlabel.show()
		$MarginContainer/Label.hide()
		
		$FUNKYTextureRect.show()
		$TextureRect.hide()
		move_texture_around()
		
		$song.stop()
		$FunkyBall.play()
		
		$MarginContainer/VBoxContainer/play.text = "FUNKYstart"
		$MarginContainer/VBoxContainer/options.text = "FUNKYoptions"
		$MarginContainer/VBoxContainer/lvlSelect.text = "FUNKYlevels"
		$MarginContainer/VBoxContainer/credits.text = "FUNKYcredits"
		switch_up_btn_positions()
		
		$MarginContainer/Label2.text = "yooooooooooooooooooooooooooooo"
		
		gradually_switch_colors()
		

func switch_up_btn_positions():
	while true:
		move_to_random_position($MarginContainer/VBoxContainer/play)
		await wait(0.3)
		move_to_random_position($MarginContainer/VBoxContainer/options)
		await wait(0.3)
		move_to_random_position($MarginContainer/VBoxContainer/lvlSelect)
		await wait(0.3)
		move_to_random_position($MarginContainer/VBoxContainer/credits)
		await wait(0.3)

func move_to_random_position(object):
	var t: Tween = create_tween().set_loops()
	
	t.tween_property(object, "global_position", Vector2(rng.randi_range(0, 800), rng.randi_range(0, 570)), 0.2)

func move_texture_around():
	var t: Tween = create_tween()
	
	t.tween_property($FUNKYTextureRect, "global_position", Vector2(
	rng.randi_range(-200, 400),
	rng.randi_range(-200, 300)),
	0.7)
	
	t.tween_callback(move_texture_around)

func gradually_switch_colors():
	var t: Tween = create_tween().set_loops()
	t.tween_property($ColorRect, "color", Color.DEEP_PINK, 0.2)
	t.tween_property($ColorRect, "color", Color.GREEN, 0.2)
	t.tween_property($ColorRect, "color", Color.YELLOW, 0.2)
	t.tween_property($ColorRect, "color", Color.RED, 0.2)
	t.tween_property($ColorRect, "color", Color.PURPLE, 0.2)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
