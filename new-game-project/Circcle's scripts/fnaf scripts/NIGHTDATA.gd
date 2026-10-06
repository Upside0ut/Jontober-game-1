class_name NightData

static var current_night := 0

# this is absolutely winged if this is too easy or too hard then idk
const NIGHTS := [
	# 1
	{ 
		"Agnese": { "ai_level": 6,  "move_interval": 7.0, "attack_time": 7.0, "time_to_repel": 1.0 },
		"Randy": { "ai_level": 5,  "move_interval": 7.0, "attack_time": 6.0, "time_to_repel": 1.0 },
		"error_chance": 0.0
	},
		
	# 2
	{ 
		"Agnese": { "ai_level": 9,  "move_interval": 6.5, "attack_time": 6.0, "time_to_repel": 1.5 },
		"Randy": { "ai_level": 8,  "move_interval": 6.5, "attack_time": 5.5, "time_to_repel": 1.2 },
		"error_chance": 0.05 
	},
	# 3
	{ 
		"Agnese": { "ai_level": 12, "move_interval": 6.0, "attack_time": 5.0, "time_to_repel": 1.8 },
		"Randy": { "ai_level": 11, "move_interval": 6.0, "attack_time": 5.0, "time_to_repel": 1.5 },
		"error_chance": 0.1 
	},
	# 4
	{ 
		"Agnese": { "ai_level": 15, "move_interval": 5.0, "attack_time": 4.5, "time_to_repel": 2.0 },
		"Randy": { "ai_level": 14, "move_interval": 5.0, "attack_time": 4.2, "time_to_repel": 1.8 },
		"error_chance": 0.2 
	},
	# 5
	{ 
		"Agnese": { "ai_level": 18, "move_interval": 4.0, "attack_time": 3.8, "time_to_repel": 2.0 },
		"Randy": { "ai_level": 17, "move_interval": 4.0, "attack_time": 3.6, "time_to_repel": 2.0 },
		"error_chance": 0.3 
	}
]

static func get_diff(name):
	
	# returns which the dictionary u need based on current_night 
	var night = NIGHTS[clampi(current_night, 0, NIGHTS.size() - 1)]
	return night[name]
