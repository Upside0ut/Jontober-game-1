extends Node

class Level:
	var lvl_name
	var path
	var is_b_route
	
	var is_current_level = false
	
	func _init(lvl_name:String, path:String, is_b_route:bool):
		self.lvl_name = lvl_name
		self.path = path
		self.is_b_route = is_b_route
	
	func set_current_level() -> bool:
		if (Global.current_level == self):
			printerr("could not set, lvl is current already")
			print(self.lvl_name)
			return false
		
		if (Global.current_level == null):
			print("Setting from menu, level: ")
			print(self.lvl_name)
		else:
			print("changing lvl current: ")
			print(Global.current_level.lvl_name)
			print("to new: ")
			print(self.lvl_name)
		
		Global.current_level = self
		return true

@onready var level1 = Level.new("level1", "res://levels/level_01.tscn", false)
@onready var level2 = Level.new("level2", "res://levels/level_02.tscn", false)
@onready var level3 = Level.new("level3", "res://levels/level_03.tscn", false)
@onready var level4 = Level.new("level4", "res://levels/level_04.tscn", false)
@onready var level4_hard = Level.new("level4_hard", "res://levels/level_04_hard_version.tscn", true)
@onready var level5 = Level.new("level5", "res://levels/level_05.tscn", false)
@onready var level_boss = Level.new("level_boss", "res://levels/level_boss.tscn", false)
@onready var level_museum = Level.new("level_museum", "res://levels/museum_1.tscn", false)

@onready var level_array = [
	level1,
	level2,
	level3,
	level4,
	level4_hard,
	level5,
	level_boss,
	level_museum
]

@onready var level_array_hard_excluded = [
	level1,
	level2,
	level3,
	level4,
	level5,
	level_boss,
	level_museum
]

var current_level:Level = null
@onready var highest_unlocked_level:Level = level1 #add smth to count up and then start this instead of always 1, but i dont wanna

var global_time = 0.0

# checkpoints can made using the checkpoint scene and adding collision
# the checkpoint var is reset by calling reset_checkpoint
var checkpoint: Vector2

var destroyed_wall = false

func _ready() -> void:
	load_achievement_progress()
	NightData.load_night()
	
	force_all_true_reset_user_config()

func _process(delta: float) -> void:
	global_time += delta
	
	# if you guys use any shaders, use 'global uniform float global_shadertime' instead of TIME
	RenderingServer.global_shader_parameter_set("global_shadertime", global_time)

func reset_user_config():
	if !FileAccess.file_exists("user://levels.cfg"):
		var config = ConfigFile.new()
		for level in level_array:
			config.set_value("LEVELS", level.lvl_name, false)
		
		config.save("user://levels.cfg")

func force_reset_user_config():
	var config = ConfigFile.new()
	for level in level_array:
		config.set_value("LEVELS", level.lvl_name, false)
	
	config.save("user://levels.cfg")

func force_all_true_reset_user_config():
	var config = ConfigFile.new()
	for level in level_array:
		config.set_value("LEVELS", level.lvl_name, true)
	
	config.save("user://levels.cfg")

func change_to_level(level:Level):
	if level.set_current_level():
		get_tree().call_deferred("change_scene_to_file", level.path)
		Global.reset_checkpoint()
	else:
		printerr("smth went wrong when changing lvls, going back to title.")
		get_tree().call_deferred("change_scene_to_file", "res://scenes/titlescreen.tscn")

func change_from_lvl_to_menu(path: String):
	for lvl in level_array:
		if path == lvl.path:
			printerr("could not go to scene, path is level path")
			return
	
	if current_level != null:
		current_level = null
		get_tree().call_deferred("change_scene_to_file", path)
		print("current level is now null")

func change_to_boss_fancy():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/pre_boss.tscn")

func add_current_level_to_config():
	var config = ConfigFile.new()
	var err: Error = config.load("user://levels.cfg")
	if err != OK:
		return
	config.set_value("LEVELS", current_level.lvl_name, true)
	config.save("user://levels.cfg")
	print("Level set to true in file: ", current_level.lvl_name)

func check_previous_level_beaten(level: Level):
	var config = ConfigFile.new()
	var err: Error = config.load("user://levels.cfg")
	if err != OK:
		return
	
	var selected_lvl
	
	match level:
		level1: return true
		level2: selected_lvl = level1
		level3: selected_lvl = level2
		level4: selected_lvl = level3
		level5: selected_lvl = level4
		level_boss: selected_lvl = level5
	
	return config.get_value("LEVELS", selected_lvl.lvl_name)

func switch_levels_via_victory_screen():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/victory_screen.tscn")

func switch_to_next_level():
	match current_level:
		level1: change_to_level(level2)
		level2: change_to_level(level3)
		level3: change_to_level(level4)
		level4: change_to_level(level5)
		level5: change_to_boss_fancy()

func toggle_b_route():
	if (current_level.is_b_route):
		switch_back_from_b_route()
	else:
		switch_to_b_route()

func switch_to_b_route():
	match current_level:
		level4: change_to_level(level4_hard)
		#level1: level1_hard.set...etc

func switch_back_from_b_route():
	match current_level:
		level4_hard: change_to_level(level4)


func reset_checkpoint():
	checkpoint = Vector2(0, 0)
	print("reset checkpoint to 0, 0")

## returns string of the achievement that corresponds to the given level or null if no achievement is connected to beating the lvl
func get_lvl_corresponding_achievement(level:Level):
	match level:
		level4_hard: return "lvl4_b_route_beaten"
		_: return null

# used in the achievement display
var achievement_queue := []
var current_skin_name : String
var current_skin_png : Resource

static var achievements = {
	# gives boss skin
	"boss_beaten" : false,
	# gives agnese skin
	"night_five_beaten" : false,
	# gives free randy
	"game_beaten" : false,
	# gives nubby
	"lvl4_b_route_beaten" : false,
	# gives moron randy
	"lvl5_secret_entrance"  : false
}

static var skins = {
"default" : true,
"haprandy" : true,
"boss_skin" : false,
"falling_guy" : true,
"free_randy" : false,
"wheel" : true,
"angel_randy" : true,
"bad_merch" : true,
"nubby" : false,
"punished_randy" : true,
"edgeball" : true,
"speedball" : true,
"steelball" : true,
"randerity" : true,
"moron_randy" : false,
"agnese" : false,
}

signal achievement_changed
signal achievements_cleared

var default_achievements := achievements.duplicate()
var default_skins := skins.duplicate()

## sets Achievement_Key (String) to Value (Bool), which is true by default
func set_achievement(achievement_key : String, value : bool = true):
	if(achievements.has(achievement_key)):
		if value and not achievements[achievement_key]:
			Global.achievement_queue.append(achievement_key)
	
	achievements[achievement_key] = value
	update_rewards(achievement_key)
	achievement_changed.emit()
	
	save_achievement_progress()

func update_rewards(achievement_key):
	match achievement_key:
		"boss_beaten":
			skins["boss_skin"] = true
		"night_five_beaten":
			skins["agnese"] = true
		"game_beaten":
			skins["free_randy"] = true
		"lvl4_b_route_beaten":
			skins["nubby"] = true
		"lvl5_secret_entrance":
			skins["moron_randy"] = true

func save_achievement_progress():
	var config = ConfigFile.new()
	config.set_value("achievements", "achievement_key", achievements)
	config.set_value("unlocked_skins", "skins_key", skins)
	config.save("user://achievements.cfg")

func load_achievement_progress():
	
	var config = ConfigFile.new()
	if config.load("user://achievements.cfg") != OK:
		
		save_achievement_progress()
		load_achievement_progress()
		
		return
	var saved_achievements : Dictionary = config.get_value("achievements", "achievement_key", {})
	var saved_skins : Dictionary = config.get_value("unlocked_skins", "skins_key", {})
	
	for key in achievements:
		if saved_achievements.has(key):
			achievements[key] = saved_achievements[key]
	
	for key in skins:
		if saved_skins.has(key):
			skins[key] = saved_skins[key]
	
	save_achievement_progress()

func clear_progress():
	achievement_queue.clear()
	skins = default_skins.duplicate()
	achievements = default_achievements.duplicate()
	save_achievement_progress()
	achievements_cleared.emit()
