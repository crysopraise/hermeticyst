extends "res://scripts/enemies/ranged_enemy.gd"

func attack_state(delta):
	if !$BulletSpawner.beam_active:
		face_target(TURN_SPEED * $BulletSpawner.target_slow, delta)
