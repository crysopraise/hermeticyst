extends Area

func shoot(camera):
	var position = get_viewport().size / 2
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * 500
	var collision = get_world().direct_space_state.intersect_ray(from, to, [], 1)
	if collision:
		var length = global_transform.origin.distance_to(collision.position)
		$CollisionShape.shape.height = length
		$MeshInstance.mesh.mid_height = length
		$MeshInstance2.mesh.mid_height = length/1.25
		$MeshInstance3.mesh.height = length
		look_at(collision.position, Vector3.UP)
		transform.origin += -transform.basis.z * (length / 2)
