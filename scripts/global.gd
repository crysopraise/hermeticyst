extends Node

var enemy_total: float = 0
var enemy_count: float = 0

func _ready():
	randomize()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()

func on_level_load():
	enemy_total = get_tree().get_nodes_in_group('enemies').size()
	enemy_count = enemy_total

func on_enemy_die():
	enemy_count -= 1
	get_tree().call_group('hazard', 'set_blood_level', 1 - (enemy_count / enemy_total))
	if enemy_count == 0:
		get_tree().call_group('bullets', 'die')
		get_tree().call_group('door', '_on_room_clear')
		get_tree().current_scene.add_child(preload("res://scenes/gui/room_clear_overlay.tscn").instance())

func on_player_die():
	get_tree().current_scene.add_child(preload("res://scenes/gui/death_overlay.tscn").instance())

