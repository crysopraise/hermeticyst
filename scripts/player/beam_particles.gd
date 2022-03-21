extends Particles

export var MAX_SPEED_SCALE = 1.5
export var SPEED_ACCELERATION = 0.25

func _process(delta):
	speed_scale += delta * SPEED_ACCELERATION

func die():
	emitting = false
	process_material.gravity = Vector3(0, 0, 10)
	process_material.radial_accel = -15
	$Timer.start(lifetime)
