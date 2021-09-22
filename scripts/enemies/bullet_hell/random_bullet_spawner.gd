extends "res://scripts/enemies/bullet_hell/bullet_spawner.gd"

func _on_shoot():
	var spawns = $SpawnContainer.get_children()
	var spawn = spawns[randi() % spawns.size()]
	var bullet = bullet_scn.instance()
	bullet.move_forward = false
	bullet.speed = bullet.speed * rand_range(1, 5)
	bullet.size = BULLET_SIZE
	get_tree().current_scene.add_child(bullet)
	bullet.transform.origin = spawn.global_transform.origin
	bullet.look_at(global_transform.origin, Vector3.LEFT)

