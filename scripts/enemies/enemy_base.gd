extends Spatial

# Constants
export var TURN_SPEED = 1

# Nodes
onready var player = get_tree().current_scene.get_node('Player')

# Variables
var is_idle = true

func _ready():
	look_at(player.translation, Vector3.UP)

func _physics_process(delta):
	if is_idle:
		pass
	else:
		attack_state(delta)

func attack_state(delta):
	pass

# Smoothly turn to face player
func face_player(delta):
	var target_rotation = transform.looking_at(player.translation, Vector3.UP)
	transform = transform.interpolate_with(target_rotation, delta * TURN_SPEED)

func end_idle():
	is_idle = false

