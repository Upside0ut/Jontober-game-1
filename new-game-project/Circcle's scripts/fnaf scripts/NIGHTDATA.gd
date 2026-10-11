class_name NightData

static var current_night := 0
static var beaten_bronze_mode := false
static var beaten_silver_mode := false
static var beaten_gold_mode := false

static var bronze_active := false
static var silver_active := false
static var gold_active := false

# this is absolutely winged if this is too easy or too hard then idk
static var NIGHTS = [
	# 1
	{ "Agnese": get_stats(6),  "Randy": get_stats(5), "error_chance": 0.0},
	# 2
	{ "Agnese": get_stats(9),  "Randy": get_stats(8), "error_chance": 0.05},
	# 3
	{ "Agnese": get_stats(12), "Randy": get_stats(11), "error_chance": 0.1},
	# 4
	{ "Agnese": get_stats(15), "Randy": get_stats(14), "error_chance": 0.25},
	# 5
	{ "Agnese": get_stats(18), "Randy": get_stats(17), "error_chance": 0.33},
]

static func get_stats(ai_level: int, move_offset := 0.0) -> Dictionary:
	return {
		"ai_level": ai_level,
		"move_interval": remap(ai_level, 6, 18, 7.0, 4.7) + move_offset,
		"attack_time": remap(ai_level, 6, 18, 7.0, 4.8),
		"time_to_repel": remap(ai_level, 6, 18, 1.0, 2.0),
	}

# before nerf 1: m_i = 4.0, a_t = 3.5
# before nerf 2: m_i = 4.5, a_t = 4.2

#region explanation_for_stats
# this is what get_stats is mapping to, i wrote this then realized
# everything needs to be derived from just the ai_level
#{ 
		#"Agnese": { "ai_level": 6,  "move_interval": 7.0, "attack_time": 7.0, "time_to_repel": 1.0 },
		#"Randy": { "ai_level": 5,  "move_interval": 7.0, "attack_time": 6.0, "time_to_repel": 1.0 },
		#"error_chance": 0.0
	#},
#
	## 2
	#{ 
		#"Agnese": { "ai_level": 9,  "move_interval": 6.5, "attack_time": 6.0, "time_to_repel": 1.5 },
		#"Randy": { "ai_level": 8,  "move_interval": 6.5, "attack_time": 5.5, "time_to_repel": 1.2 },
		#"error_chance": 0.05 
	#},
	## 3
	#{ 
		#"Agnese": { "ai_level": 12, "move_interval": 6.0, "attack_time": 5.0, "time_to_repel": 1.8 },
		#"Randy": { "ai_level": 11, "move_interval": 6.0, "attack_time": 5.0, "time_to_repel": 1.5 },
		#"error_chance": 0.1 
	#},
	## 4
	#{ 
		#"Agnese": { "ai_level": 15, "move_interval": 5.0, "attack_time": 4.5, "time_to_repel": 2.0 },
		#"Randy": { "ai_level": 14, "move_interval": 5.0, "attack_time": 4.2, "time_to_repel": 1.8 },
		#"error_chance": 0.2 
	#},
	## 5
	#{ 
		#"Agnese": { "ai_level": 18, "move_interval": 4.0, "attack_time": 3.8, "time_to_repel": 2.0 },
		#"Randy": { "ai_level": 17, "move_interval": 4.0, "attack_time": 3.6, "time_to_repel": 2.0 },
		#"error_chance": 0.3 
	#}
#endregion

static var custom_night := false
static var custom_data := {}

static func start_custom(agnese_level: int, randy_level: int, error: float, plinko_night_advance: bool, alarm_stall: bool, flash_stall: bool):
	custom_data = {
		"Agnese": get_stats(agnese_level),
		"Randy": get_stats(randy_level, 0.3),
		"error_chance": error,
		"plinko_night_advance": plinko_night_advance,
		"alarm_stall": alarm_stall,
		"flash_stall": flash_stall
	}
	custom_night = true

static func get_diff(name):
	# returns which the dictionary u need based on current_night 
	if custom_night:
		return custom_data[name]
	var night = NIGHTS[clampi(current_night, 0, NIGHTS.size() - 1)]
	return night[name]

static func save_night():
	var config = ConfigFile.new()
	config.set_value("progress", "current_night", current_night)
	config.set_value("progress", "beaten_bronze_mode", beaten_bronze_mode)
	config.set_value("progress", "beaten_silver_mode", beaten_silver_mode)
	config.set_value("progress", "beaten_gold_mode", beaten_gold_mode)
	config.save("user://night.cfg")

static func load_night():
	var config = ConfigFile.new()
	if config.load("user://night.cfg") != OK:
		return
	current_night = config.get_value("progress", "current_night", 0)
	beaten_bronze_mode = config.get_value("progress", "beaten_bronze_mode", false)
	beaten_silver_mode = config.get_value("progress", "beaten_silver_mode", false)
	beaten_gold_mode = config.get_value("progress", "beaten_gold_mode", false)
