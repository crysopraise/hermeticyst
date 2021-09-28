extends Spatial

# Constants
export var SPEED = 20
export var TURN_SPEED = 2.0
export var AGRO_DELAY = 0

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
func face_player(turn_speed, delta):
	var target_rotation = transform.looking_at(player.translation, Vector3.UP)
	transform = transform.interpolate_with(target_rotation, delta * turn_speed)

func end_idle():
	if AGRO_DELAY:
		$Timer.wait_time = AGRO_DELAY
		$Timer.start()
		return
	is_idle = false

func _on_timeout():
	if is_idle:
		is_idle = false
		return

func die():
	queue_free()
	Global.on_enemy_die()

