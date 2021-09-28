extends "res://scripts/enemies/melee_enemy.gd"

func attack(player_dot):
	is_attacking = true
	$Timer.wait_time = ATTACK_TIME
	$Timer.start()

func die():
	if is_attacking and $AttackHitbox.get_overlapping_areas():
		return
	.die()

