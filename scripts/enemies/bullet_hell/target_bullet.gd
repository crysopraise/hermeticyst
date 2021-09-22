extends "res://scripts/enemies/bullet_hell/simple_bullet.gd"

export var INITIAL_SPEED = 5

var is_targetting = false
var has_targeted = false

func move(delta):
	if not is_targetting:
		if has_targeted:
			translate(Vector3.FORWARD * speed * delta)
		else:
			translate(Vector3.BACK * INITIAL_SPEED * delta)

func _on_target():
	if not has_targeted:
		is_targetting = true
		has_targeted = true
		$TargetTimer.start()
	else:
		look_at(get_tree().current_scene.get_node("Player").transform.origin, Vector3.UP)
		is_targetting = false

