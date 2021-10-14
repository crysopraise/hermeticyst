extends "res://scripts/enemies/enemy_base.gd"

# Constants
export var ATTACK_DISTANCE = 10
export var ACCELERATION = 0.05
export var DRAG = 0.025
export var KNOCK_BACK_SPEED = 35
export var PLAYER_KNOCK_BACK_SPEED = 20
export var ATTACK_ANGLE = 0.7
export var ATTACK_TIME = 0.3
export var COOLDOWN_TIME = 1
export var STUN_TIME = 1
export var RAY_OFFSET = 3
export var RAY_LENGTH = 10

# Scenes
onready var attack_scn = preload("res://scenes/enemies/stabby_attack.tscn")

var velocity = Vector3.ZERO
var is_attacking = false
var on_cooldown = false
var is_stunned = false
var enemy_attack


func avoid_collisions(turn) -> Vector3:
	var avoid_dict = {}
	var casts = {}
	casts.right = cast_collision_ray(transform.basis.x * RAY_OFFSET, -transform.basis.z)
	casts.left = cast_collision_ray(-transform.basis.x * RAY_OFFSET, -transform.basis.z)
	casts.up = cast_collision_ray(transform.basis.y * RAY_OFFSET, -transform.basis.z)
	casts.down = cast_collision_ray(-transform.basis.y * RAY_OFFSET, -transform.basis.z)
	if casts:
		if casts.right and casts.left:
# 			var right_hits = 0
# 			if cast_collision_ray(
# 					transform.basis.x * RAY_OFFSET,
# 					(-transform.basis.z).rotated(transform.basis.y, -deg2rad(45)),
# 					RAY_LENGTH):
# 				right_hits += 1
# 				if cast_collision_ray(
# 						transform.basis.x * RAY_OFFSET,
# 						transform.basis.x,
# 						RAY_LENGTH / 2):
# 					right_hits += 1
# 
# 			var left_hits = 0
# 			if cast_collision_ray(
# 					-transform.basis.x * RAY_OFFSET,
# 					(-transform.basis.z).rotated(transform.basis.y, deg2rad(45)),
# 					RAY_LENGTH):
# 				left_hits += 1
# 				if cast_collision_ray(
# 						-transform.basis.x * RAY_OFFSET,
# 						-transform.basis.x,
# 						RAY_LENGTH / 2):
# 					left_hits +=1
			var right_hits = cast_to_side(transform.basis.x, transform.basis.y, -deg2rad(45))
			var left_hits = cast_to_side(-transform.basis.x, transform.basis.y, deg2rad(45))

			if right_hits <= left_hits:
				avoid_dict.y = turn
			else:
				avoid_dict.y = -turn
		elif casts.right:
			avoid_dict.y = turn
		elif casts.left:
			avoid_dict.y = -turn

		if casts.up and casts.down:
# 			var up_hits = 0
# 			if cast_collision_ray(
# 					transform.basis.y * RAY_OFFSET,
# 					(-transform.basis.z).rotated(transform.basis.x, deg2rad(45)),
# 					RAY_LENGTH):
# 				up_hits += 1
# 				if cast_collision_ray(
# 						transform.basis.y * RAY_OFFSET,
# 						transform.basis.y,
# 						RAY_LENGTH / 2):
# 					up_hits += 1
# 				
# 
# 			var down_hits = 0
# 			if cast_collision_ray(
# 					-transform.basis.y * RAY_OFFSET,
# 					(-transform.basis.z).rotated(transform.basis.x, -deg2rad(45)),
# 					RAY_LENGTH):
# 				down_hits += 1
# 				if cast_collision_ray(
# 						-transform.basis.y * RAY_OFFSET,
# 						-transform.basis.y,
# 						RAY_LENGTH / 2):
# 					down_hits += 1
			var up_hits = cast_to_side(transform.basis.y, transform.basis.x, deg2rad(45))
			var down_hits = cast_to_side(-transform.basis.y, transform.basis.x, -deg2rad(45))

			if up_hits <= down_hits:
				avoid_dict.x = turn
			else:
				avoid_dict.x = -turn
		elif casts.up:
			avoid_dict.x = turn
		elif casts.down:
			avoid_dict.x = -turn

		var center_cast = cast_collision_ray(Vector3.ZERO, -transform.basis.z)
		if center_cast:
			avoid_dict.slowdown = center_cast.position.distance_squared_to(transform.origin) / (RAY_LENGTH*RAY_LENGTH) / 2
# 			if avoid_dict.slowdown < 0.4:
# 				avoid_dict.slowdown = -1
	
	return avoid_dict

func cast_to_side(side: Vector3, rotate_axis: Vector3, diagonal_angle: float):
	var hit_rank = 0
	var diagonal_cast = cast_collision_ray(
		side * RAY_OFFSET,
		(-transform.basis.z).rotated(transform.basis.x, diagonal_angle),
		RAY_LENGTH)
	if diagonal_cast:
		hit_rank += transform.origin.distance_squared_to(diagonal_cast.position)
		var side_cast = cast_collision_ray(
			-transform.basis.y * RAY_OFFSET,
			-transform.basis.y,
			RAY_LENGTH / 2)
		if side_cast:
			hit_rank += transform.origin.distance_squared_to(side_cast.position)
	return hit_rank
	
func cast_collision_ray(offset: Vector3, direction: Vector3, length: float = RAY_LENGTH):
	var start = global_transform.origin + offset
	var end = start + direction * length
	LineDrawer.add_line(start, end)
	return get_world().direct_space_state.intersect_ray(start, end, [], 2)

func attack_state(delta):
	var direction_to_player = translation.direction_to(player.translation)
	var player_dot = direction_to_player.dot(-transform.basis.z)
	var target_velocity = -transform.basis.z * SPEED

	if !is_attacking and !on_cooldown:
		var old_transform = transform
		var avoid_dict = avoid_collisions(deg2rad(60) * delta)
		if avoid_dict:
			if avoid_dict.has("y"):
				print("turning left" if avoid_dict.y > 0 else "turning right")
				rotate_object_local(transform.basis.y, avoid_dict.y)
			if avoid_dict.has("x"):
				print("turning down" if avoid_dict.x > 0 else "turning up")
				rotate_object_local(transform.basis.x, avoid_dict.x)
			if avoid_dict.has("slowdown"):
				target_velocity *= avoid_dict.slowdown
		else:
			face_player(TURN_SPEED, delta)

	if !is_stunned:
		print('accelrating')
		velocity = velocity.linear_interpolate(target_velocity, ACCELERATION)
	else:
		velocity = velocity.linear_interpolate(Vector3.ZERO, DRAG)

	print(velocity)
	#translate(velocity * delta)
	move_and_slide(velocity)
	var distance_to_player = translation.distance_to(player.translation)
	if distance_to_player < ATTACK_DISTANCE and player_dot > ATTACK_ANGLE and !is_attacking and !on_cooldown:
		attack(player_dot)

func attack(player_dot):
		is_attacking = true
		enemy_attack = attack_scn.instance()
		enemy_attack.get_node('Hitbox').connect('body_entered', self, '_on_hit_player')
		enemy_attack.get_node('Hitbox').connect('area_entered', self, '_on_hit_attack')
		add_child(enemy_attack)
		$Timer.wait_time = ATTACK_TIME
		$Timer.start()

func die():
	if is_instance_valid(enemy_attack) and enemy_attack.get_node('Hitbox').get_overlapping_areas():
		return
	.die()

func _on_hit_player(_body):
	Global.on_player_die()

func _on_hit_attack(_area):
	if KNOCK_BACK_SPEED:
		is_stunned = true
		velocity = Vector3.BACK * KNOCK_BACK_SPEED
	player.knock_back(PLAYER_KNOCK_BACK_SPEED)

func _on_timeout():
	._on_timeout()
	if is_attacking:
		if is_instance_valid(enemy_attack):
			enemy_attack.queue_free()
		is_attacking = false
		on_cooldown = true
		$Timer.wait_time = STUN_TIME if is_stunned else COOLDOWN_TIME
		$Timer.start()
		return
	if on_cooldown:
		on_cooldown = false
	if is_stunned:
		is_stunned = false

