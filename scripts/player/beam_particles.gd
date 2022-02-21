extends Particles

func die():
	emitting = false
	process_material.gravity = Vector3(0, 0, 10)
	process_material.radial_accel = -15
	$Timer.start(lifetime)
