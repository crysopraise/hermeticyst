extends Spatial

func _enter_tree():
	# Instance GUI before player loads
	var gui = preload("res://scenes/gui/player_gui.tscn").instance()
	add_child(gui)

func _ready():
	Global.on_level_load()
