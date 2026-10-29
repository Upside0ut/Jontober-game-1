extends Control

var funky_mode := false

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/FUNKYlabel.hide()
	$FUNKYTextureRect.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if funky_mode: return
	if (Input.is_action_pressed("FUNKY_F") and
		Input.is_action_pressed("FUNKY_U") and
		Input.is_action_pressed("FUNKY_N") and
		Input.is_action_pressed("FUNKY_K") and
		Input.is_action_pressed("FUNKY_Y")):
		funky_mode = true
		$Parallax2D/AnimationPlayer.speed_scale += 1
		$Parallax2D/AnimatedSprite2D.speed_scale += 1
		
		$MarginContainer/FUNKYlabel.show()
		$MarginContainer/Label.hide()
		
		$FUNKYTextureRect.show()
		$TextureRect.hide()
		move_texture_around()
		
		$song.stop()
		$FunkyBall.play()
		
		$MarginContainer/HBoxContainer/VBoxContainer/play.text = "FUNKYstart"
		$MarginContainer/HBoxContainer/VBoxContainer/options.text = "FUNKYoptions"
		$MarginContainer/HBoxContainer/VBoxContainer/lvlSelect.text = "FUNKYlevels"
		$MarginContainer/HBoxContainer/VBoxContainer/credits.text = "FUNKYcredits"
		$MarginContainer/HBoxContainer/skins.text = "FUNKYskins"
		switch_up_btn_positions()
		
		$MarginContainer/Label2.text = "yooooooooooooooooooooooooooooo"
		
		$ColorRect.color = Color.WHITE
		gradually_switch_colors([$ColorRect,$Parallax2D/AnimatedSprite2D])

func switch_up_btn_positions():
	while true:
		move_to_random_position($MarginContainer/HBoxContainer/VBoxContainer/play)
		await wait(0.3)
		move_to_random_position($MarginContainer/HBoxContainer/VBoxContainer/options)
		await wait(0.3)
		move_to_random_position($MarginContainer/HBoxContainer/VBoxContainer/lvlSelect)
		await wait(0.3)
		move_to_random_position($MarginContainer/HBoxContainer/VBoxContainer/credits)
		await wait(0.3)
		move_to_random_position($MarginContainer/HBoxContainer/skins)
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

func gradually_switch_colors(nodes : Array):
	for node in nodes:
		var t: Tween = create_tween().set_loops()
		t.tween_property(node, "modulate", Color.DEEP_PINK, 0.2)
		t.tween_property(node, "modulate", Color.GREEN, 0.2)
		t.tween_property(node, "modulate", Color.YELLOW, 0.2)
		t.tween_property(node, "modulate", Color.RED, 0.2)
		t.tween_property(node, "modulate", Color.PURPLE, 0.2)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if Input.is_key_pressed(KEY_1) \
		and Input.is_key_pressed(KEY_9) \
		and Input.is_key_pressed(KEY_8) \
		and Input.is_key_pressed(KEY_7):
			get_tree().change_scene_to_file("res://scenes/fnaf_menu.tscn")
