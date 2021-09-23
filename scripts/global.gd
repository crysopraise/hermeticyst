extends Node

var enemy_count = 0

func on_enemy_die():
	enemy_count -= 1
	if enemy_count == 0:
		get_tree().call_group('bullets', 'die')
		get_tree().call_group('door', '_on_room_clear')
		get_tree().current_scene.add_child(preload("res://scenes/gui/room_clear_overlay.tscn").instance())

func on_player_die():
	var player = get_tree().current_scene.get_node('Player')
	if !player.is_dead:
		player.is_dead = true
		get_tree().current_scene.add_child(preload("res://scenes/gui/death_overlay.tscn").instance())

