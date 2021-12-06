extends Node

var gui

var enemy_total: float = 0
var enemy_count: float = 0
var current_level_type = 0

func _ready():
	randomize()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()

func on_level_load(level_type, initial_blood_level):
	BulletManager.reset_pools()
	var message = ''
	current_level_type = level_type
	enemy_total = get_tree().get_nodes_in_group('enemies').size()
	if level_type == Level.LevelType.PURGE:
		enemy_count = enemy_total
		message = 'PURGE'
	if level_type == Level.LevelType.ESCAPE:
		get_tree().call_group('door', '_on_room_clear')
		message = 'ESCAPE'
	
	get_tree().call_group('hazard', 'set_blood_level', initial_blood_level)
	gui = get_tree().current_scene.get_node('GUI')
	gui.display_message(message, 60)

func reset_level():
	BulletManager.reset_bullets()
	get_tree().reload_current_scene()

func agro_enemies():
	get_tree().call_group('enemies', 'alert_player_moved')
	if gui:
		gui.clear_message()

func on_enemy_die():
	get_tree().call_group('hazard', 'add_blood_level', 1 / enemy_total)
	if current_level_type == Level.LevelType.PURGE:
		enemy_count -= 1
		var player = get_tree().current_scene.get_node('Player')
		if enemy_count == 0 and !player.is_dead:
			get_tree().call_group('bullets', 'die')
			get_tree().call_group('door', '_on_room_clear')
			get_tree().current_scene.add_child(preload("res://scenes/gui/room_clear_overlay.tscn").instance())

func on_player_die():
	get_tree().current_scene.add_child(preload("res://scenes/gui/death_overlay.tscn").instance())
