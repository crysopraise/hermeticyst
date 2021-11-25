extends Spatial

export var next_level = ''

var room_cleared = false
var player_in_range = false

func _physics_process(_delta):
	if room_cleared and player_in_range and Input.is_action_just_pressed('attack'):
		if next_level:
			get_tree().change_scene("res://scenes/levels/" + next_level + ".tscn")
		else:
			push_warning("No level assigned to door.")
			get_tree().reload_current_scene()

func _on_room_clear():
	room_cleared = true
	$Collision.connect('body_entered', self, '_player_enter')
	$Collision.connect('body_exited', self, '_player_exit')

func _player_enter(_body):
	player_in_range = true

func _player_exit(_body):
	player_in_range = false

