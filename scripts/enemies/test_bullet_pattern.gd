extends "res://scripts/enemies/test_bullet_spawner.gd"

func _ready():
#	PATTERN = [
#		{ 
#			'type': 'spread_shot',
#			'args': [4, 50, 0.2, 90, 0, 0]
#		},
#		{ 
#			'type': 'spread_shot',
#			'args': [4, 50, 0.2, 90, 0, -10]
#		},
#		{ 
#			'type': 'spread_shot',
#			'args': [4, 50, 0.2, 90, 0, -20]
#		},
#		{ 
#			'type': 'spread_shot',
#			'args': [4, 50, 0.2, 90, 0, -30]
#		}
#	]
	PATTERN = [
		{
			'step': 0,
			'type': 'spread_shot',
			'args': [10, 360, 0, 0]
		},
		{
			'step': 0,
			'type': 'spread_shot',
			'args': [10, 360, 0.5, 0]
		},
	]
