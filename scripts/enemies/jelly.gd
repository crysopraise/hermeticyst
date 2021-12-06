extends "res://scripts/enemies/melee_enemy.gd"

export var ATTACK_SPEED = 50
var TARGET_MARGIN = 20

func attack_state(delta):
	var target_velocity = -transform.basis.z * ATTACK_SPEED
	velocity = velocity.linear_interpolate(target_velocity, ACCELERATION)
	velocity = move_and_slide(velocity)
	LineDrawer.add_line(transform.origin, transform.origin + (-transform.basis.z * $Timer.wait_time * ATTACK_SPEED))

func attack():
	transform = transform.looking_at(player.transform.origin, Vector3.UP)
	var sight_collision = cast_collision_ray(
		Vector3.ZERO,
		transform.origin.direction_to(player.transform.origin),
		ATTACK_DISTANCE + TARGET_MARGIN
	)
	if !sight_collision or \
			transform.origin.distance_squared_to(sight_collision.position) > \
			transform.origin.distance_squared_to(player.transform.origin):
		animation_player.play(ANIM_PREFIX + '_move', 0.1, ATTACK_ANIM_SPEED)
		is_attacking = true
		var end_point = sight_collision.position - \
				(-transform.basis.z * TARGET_MARGIN) if \
				sight_collision else \
				transform.origin + (-transform.basis.z * ATTACK_DISTANCE)
		$Timer.start(transform.origin.distance_to(end_point) / ATTACK_SPEED)

func is_colliding_with_attack():
	var player_behind = acos(player_dot) > deg2rad(90)
	return $AttackHitbox.get_overlapping_areas() and !player_behind

func die():
	if .die():
		return # Return early if death failed
	$AttackHitbox/CollisionShape.disabled = true
	$Model/jellyfishmantle.visible = false
