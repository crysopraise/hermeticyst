extends "res://scripts/enemies/attacks/bullet.gd"

var base_wait = 0 # Set by enemy
var direction = Vector3.FORWARD
var changing_direction = false

func move(delta):
	if not changing_direction:
		var distance = speed * delta
		translate((Vector3.FORWARD if move_forward else Vector3.BACK) * distance)
		update_distance_traveled(distance)

func fire(params):
	.fire(params)
	changing_direction = false

func _on_drift():
	if not changing_direction:
		rotate_x(rand_range(0, TAU))
		rotate_y(rand_range(0, TAU))
		rotate_z(rand_range(0, TAU))
		changing_direction = true
		$DriftTimer.wait_time = base_wait - $DriftTimer.wait_time
		$DriftTimer.start()
	else:
		changing_direction = false
