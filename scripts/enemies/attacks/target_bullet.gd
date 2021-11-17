extends "res://scripts/enemies/attacks/bullet.gd"

export var INITIAL_SPEED = 5

var is_targetting = false
var has_targeted = false

func move(delta):
	if not is_targetting:
		var distance
		if has_targeted:
			distance = speed * delta
			translate(Vector3.FORWARD * distance)
		else:
			distance = INITIAL_SPEED * delta
			translate(Vector3.BACK * distance)
		update_distance_traveled(distance)

func fire(position, direction):
	.fire(position, direction)
	$TargetTimer.start()

func _on_target():
	if not has_targeted:
		is_targetting = true
		has_targeted = true
		$TargetTimer.start()
	else:
		look_at(get_tree().current_scene.get_node("Player").transform.origin, Vector3.UP)
		is_targetting = false

