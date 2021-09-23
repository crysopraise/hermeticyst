extends "res://scripts/enemies/enemy_base.gd"

onready var bullet_spawner = $BulletSpawner

func attack_state(delta):
	if !bullet_spawner.is_shooting:
		face_player(delta)

func end_idle():
	.end_idle()
	$BulletSpawner.start_attack()

