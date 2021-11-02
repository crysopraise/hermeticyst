extends "res://scripts/enemies/melee_enemy.gd"

func die():
	if attack and attack.get_node('Hitbox').get_overlapping_areas():
		return
	.die()

