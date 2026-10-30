extends Node

class Level:
	var lvl_name
	var path
	
	var is_current_level = false
	
	func _init(lvl_name:String, path:String):
		self.lvl_name = lvl_name
		self.path = path
	
	func set_current_level():
		if (Global.current_level == self):
			printerr("could not set, lvl is current already")
			print(self.lvl_name)
			return
			
		if (Global.current_level == null):
			print("Setting from menu, level: ")
			print(self.lvl_name)
		else:
			print("changing lvl current: ")
			print(Global.current_level)
			print("to new: ")
			print(self.lvl_name)
		
		Global.current_level = self

@onready var level1 = Level.new("level1", "res://levels/level_01.tscn")
@onready var level2 = Level.new("level2", "res://levels/level_02.tscn")
@onready var level3 = Level.new("level3", "res://levels/level_03.tscn")
@onready var level4 = Level.new("level4", "res://levels/level_04.tscn")
@onready var level4_hard = Level.new("level4_hard", "res://levels/level_04_hard_version.tscn")
@onready var level5 = Level.new("level5", "res://levels/level_05.tscn")
@onready var level_boss = Level.new("level_boss", "res://levels/level_boss.tscn")
@onready var level_museum = Level.new("level_museum", "res://levels/museum_1.tscn")

var current_level:Level = null

var global_time = 0.0

# checkpoints can made using the checkpoint scene and adding collision
# the checkpoint var is reset when a level is beat
var checkpoint: Vector2

var destroyed_wall = false

func _ready() -> void:
	load_achievement_progress()
	NightData.load_night()

func _process(delta: float) -> void:
	global_time += delta
	
	# if you guys use any shaders, use 'global uniform float global_shadertime' instead of TIME
	RenderingServer.global_shader_parameter_set("global_shadertime", global_time)

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
"nubby" : true,
"punished_randy" : true,
"edgeball" : true,
"speedball" : true,
"steelball" : true,
"randerity" : true,
"moron_randy" : true,
"agnese" : false,
}

signal achievement_changed
signal achievements_cleared

var default_achievements := achievements.duplicate()
var default_skins := skins.duplicate()

## sets Achievement_Key (String) to Value (Bool), which is true by default
func set_achievement(achievement_key : String, value : bool = true):
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
