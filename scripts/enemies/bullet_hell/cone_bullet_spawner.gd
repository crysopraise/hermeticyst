extends "res://scripts/enemies/bullet_hell/bullet_spawner.gd"

export var X_ROTATE_INC = 20
export var Z_ROTATE_INC = 20
export var BULLET_RINGS = 3
export var BULLET_COUNT = 4

var bullet_rotation = 0

func shoot_state(delta):
	pass

func _on_shoot():
	for i in range(BULLET_RINGS):
		for j in range(BULLET_COUNT):
			var bullet = bullet_scn.instance().init(BULLET_KILL_TIME, BULLET_SPEED)
			get_tree().current_scene.add_child(bullet)
			bullet.transform.origin = global_transform.origin
			bullet.transform.basis = global_transform.basis
			bullet.rotate_x(deg2rad(i * X_ROTATE_INC))
			bullet.rotate(
				global_transform.basis.z,
				deg2rad(bullet_rotation + (j * (360 / BULLET_COUNT))))
	bullet_rotation += Z_ROTATE_INC

