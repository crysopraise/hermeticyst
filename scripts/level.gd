extends Spatial

func _enter_tree():
	# Instance GUI before player loads
	var gui = preload("res://scenes/gui/player_gui.tscn").instance()
	add_child(gui)

func _ready():
	# Set enemy count
	Global.enemy_count = get_tree().get_nodes_in_group('enemies').size()

