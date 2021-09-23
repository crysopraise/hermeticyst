extends Spatial

func _ready():
	Global.enemy_count = get_tree().get_nodes_in_group('enemies').size()

