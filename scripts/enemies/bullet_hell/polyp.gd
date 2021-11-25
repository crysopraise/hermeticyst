extends "res://scripts/enemies/bullet_hell/bullet_hell_base.gd"

# Constants
var MAX_ANGLE = deg2rad(30)

# Variables
var player_out_of_range = false

func active_state(delta):
	face_target(TURN_SPEED, delta)

func attack_state(delta):
#	face_target(TURN_SPEED, delta)
	if player_out_of_range:
		if check_player_out_of_range():
			player_out_of_range = true
			face_target(TURN_SPEED, delta)
		else:
			is_attacking = false
			$Timer.start(1)
	else:
		.attack_state(delta)

func _on_timeout():
	._on_timeout()
	if is_attacking:
		player_out_of_range = check_player_out_of_range()

func check_player_out_of_range():
	return transform.origin.distance_squared_to(player.transform.origin) \
			> ARGRO_RANGE_SQUARED \
			or get_world().direct_space_state.intersect_ray(
				transform.origin,
				player.transform.origin,
				[],
				1
			)

