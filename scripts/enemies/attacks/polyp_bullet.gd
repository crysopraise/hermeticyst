extends 'res://scripts/enemies/attacks/bullet.gd'

#Constants
export var TURN_SPEED = 1.75

# Variables
export var animation_finished = false
onready var player = get_tree().current_scene.get_node_or_null('Player')

func move(delta):
	if animation_finished:
		if is_instance_valid(player):
			var distance = speed * delta
			var target_rotation = global_transform.looking_at(player.global_transform.origin, Vector3.UP)
			global_transform = global_transform.interpolate_with(target_rotation, delta * TURN_SPEED)
			translate(Vector3.FORWARD * distance)
			update_distance_traveled(distance)

func fire(params):
	.fire(params)
	animation_finished = false
	$AnimationPlayer.play('grow')
