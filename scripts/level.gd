class_name Level
extends Spatial

enum LevelType {PURGE, ESCAPE}

export(LevelType) var level_type = LevelType.PURGE
export(float, 0, 1) var initial_blood_level = 0

func _enter_tree():
	# Instance GUI before player loads
	var gui = preload("res://scenes/gui/player_gui.tscn").instance()
	add_child(gui)
	gui.connect("ready", gui, "connect_signals", [ $Player ], Object.CONNECT_ONESHOT)

func _ready():
	LevelManager.on_level_load(get_tree().current_scene.filename, level_type, initial_blood_level)
