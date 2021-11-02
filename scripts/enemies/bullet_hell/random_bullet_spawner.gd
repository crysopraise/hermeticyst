extends "res://scripts/enemies/bullet_hell/bullet_spawner.gd"

func _on_shoot():
	var spawns = $SpawnContainer.get_children()
	var spawn = spawns[randi() % spawns.size()]
	var bullet = bullet_scn.instance().init(bullet_scn.KILL_TIME, bullet_scn.SPEED * rand_range(1, 5), false, BULLET_SIZE)
	get_tree().current_scene.add_child(bullet)
	bullet.transform.origin = spawn.global_transform.origin
	bullet.look_at(global_transform.origin, Vector3.LEFT)

