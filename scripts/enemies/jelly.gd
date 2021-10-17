extends "res://scripts/enemies/melee_enemy.gd"

export var ATTACK_SPEED = 50

func attack_state(delta):
	var target_velocity = -transform.basis.z * ATTACK_SPEED
	velocity = velocity.linear_interpolate(target_velocity, ACCELERATION)
	velocity = move_and_slide(velocity)

func attack():
	transform = transform.looking_at(player.transform.origin, Vector3.UP)
	var sight_collision = cast_collision_ray(Vector3.ZERO, transform.origin.direction_to(player.transform.origin), ATTACK_DISTANCE)
	if !sight_collision or transform.origin.distance_squared_to(sight_collision.position) > transform.origin.distance_squared_to(player.transform.origin):
		is_attacking = true
		var end_point = sight_collision.position if sight_collision else transform.origin + (-transform.basis.z * ATTACK_DISTANCE)
		$Timer.wait_time = transform.origin.distance_to(end_point) / ATTACK_SPEED
		$Timer.start()

func die():
	if is_attacking and $AttackHitbox.get_overlapping_areas():
		return
	.die()

