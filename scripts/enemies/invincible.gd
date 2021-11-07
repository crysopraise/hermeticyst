extends 'res://scripts/enemies/melee_enemy.gd'

func active_state(delta):
	var target_velocity = -transform.basis.z * SPEED
	target_velocity = navigate_to_target(delta, target_velocity, TURN_SPEED)
	velocity = velocity.linear_interpolate(target_velocity, ACCELERATION)
	velocity = move_and_slide(velocity)

func is_colliding_with_attack():
	return $AttackHitbox.get_overlapping_areas()

