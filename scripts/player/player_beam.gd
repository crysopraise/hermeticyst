extends Area

export var speed = 150
var fired = false
var growing = true
var total_length

func _physics_process(delta):
	var length = speed * delta
	if fired:
		if growing:
			$CollisionShape.shape.height += length
			$MeshInstance.mesh.mid_height += length
#			$MeshInstance2.mesh.mid_height += length/1.25
#			$MeshInstance3.mesh.mid_height += length
			$Particles.process_material.emission_box_extents.z += length / 2
			if $CollisionShape.shape.height >= total_length:
				growing = false
		else:
			$CollisionShape.shape.height -= length
			$MeshInstance.mesh.mid_height -= length
			$Particles.process_material.emission_box_extents.z -= length / 2
			if $CollisionShape.shape.height <= 1:
				queue_free()
		transform.origin += -transform.basis.z * (length / 2)

func shoot(camera):
	get_tree().current_scene.add_child(self)
	var position = get_viewport().size / 2
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * 500
	var collision = get_world().direct_space_state.intersect_ray(from, to, [], 1)
	if collision:
		total_length = global_transform.origin.distance_to(collision.position)
		$CollisionShape.shape.height = 1
		$MeshInstance.mesh.mid_height = 1
		$Particles.process_material.emission_box_extents.z = 1
		look_at(collision.position, Vector3.UP)
	fired = true
