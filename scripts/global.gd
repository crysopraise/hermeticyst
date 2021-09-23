extends Node

func player_die():
	get_tree().current_scene.get_node('Player').is_dead = true
	get_tree().current_scene.add_child(preload("res://scenes/gui/death_overlay.tscn").instance())

