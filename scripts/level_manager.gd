extends Node

var gui
var player

var enemy_total: float = 0
var enemy_count: float = 0
var current_level_name = ''
var current_level_type = 0
var melee_engaged_enemies = 0
var range_engaged_enemies = 0

func _ready():
	randomize()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
#
#func _process(delta):
#	var enemies = get_tree().get_nodes_in_group('enemies')

func on_level_load(level_name, level_type, initial_blood_level):
	if current_level_name != level_name and current_level_name != '':
		BulletManager.reset_pools()
	current_level_name = level_name
	current_level_type = level_type
	
	var message = ''
	enemy_total = get_tree().get_nodes_in_group('enemies').size()
	print(get_tree().get_nodes_in_group('enemies'))
	if level_type == Level.LevelType.PURGE:
		enemy_count = enemy_total
		print('setting enemy total to: ', enemy_total)
		message = 'PURGE'
	if level_type == Level.LevelType.ESCAPE:
		get_tree().call_group('door', '_on_room_clear')
		message = 'ESCAPE'
	
	gui = get_tree().current_scene.get_node('GUI')
	player = get_tree().current_scene.find_node('Player')
	player.connect("player_die", LevelManager, "on_player_die")
	player.connect("update_blood", gui, "update_blood")
	gui.call_deferred("display_message", message, 60)

	get_tree().call_group('hazard', 'set_blood_level', initial_blood_level)

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
		print('enemy killed, count: ', enemy_count)
		if enemy_count == 0 and !player.is_dead:
			get_tree().call_group('bullets', 'die')
			get_tree().call_group('door', '_on_room_clear')
			get_tree().current_scene.add_child(preload("res://scenes/gui/room_clear_overlay.tscn").instance())

func on_player_die():
	get_tree().current_scene.add_child(preload("res://scenes/gui/death_overlay.tscn").instance())
