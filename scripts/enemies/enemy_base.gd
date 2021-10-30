extends KinematicBody

# Constants
export var SPEED: int = 20
export var ACCELERATION: float = 0.05
export var TURN_SPEED: float = 4
export var AGRO_DELAY: float = 0
export var AGRO_RANGE: int = 100
export var RAY_OFFSET: float = 3
export var RAY_LENGTH: float = 10
export var ATTACK_TIME = 0.3
export var COOLDOWN_TIME = 0.5

var ARGRO_RANGE_SQUARED
var TRAPPED_FRAMES = 20
var FREE_FRAMES = 50
var AVOID_ROTATION = deg2rad(90)
var REVERSE_SPEED = -0.5

# Nodes
onready var player = get_tree().current_scene.get_node('Player')

# Variables
var velocity = Vector3.ZERO
var has_player_moved = false
var is_idle = true
var is_attacking = false
var on_cooldown = false
var frames_trapped = 0
var frames_free = 0
var target

func _ready():
	ARGRO_RANGE_SQUARED = AGRO_RANGE*AGRO_RANGE
	if player:
		look_at(player.translation, Vector3.UP)
		target = player

func _physics_process(delta):
	if is_idle:
		if player and has_player_moved and $Timer.is_stopped() and transform.origin.distance_squared_to(player.transform.origin) < ARGRO_RANGE_SQUARED:
			var sight_cast = get_world().direct_space_state.intersect_ray(transform.origin, player.transform.origin, [], 1)
			if !sight_cast:
				if AGRO_DELAY:
					$Timer.start(AGRO_DELAY)
				else:
					end_idle()
	else:
		if is_attacking:
			attack_state(delta)
		else:
			active_state(delta)

func active_state(_delta: float):
	pass

func attack_state(_delta: float):
	pass

func navigate_to_target(delta: float, target_velocity: Vector3, turn_speed: float = TURN_SPEED) -> Vector3:
	var avoid_dict = detect_collisions(AVOID_ROTATION * delta)
	if avoid_dict:
		if avoid_dict.has('trapped'):
			target_velocity *= REVERSE_SPEED
			rotate_object_local(transform.basis.y, AVOID_ROTATION * delta)
		else:
			if avoid_dict.has('y'):
				rotate_object_local(transform.basis.y, avoid_dict.y)
			if avoid_dict.has('x'):
				rotate_object_local(transform.basis.x, avoid_dict.x)
	else:
		face_target(turn_speed, delta)

	return target_velocity

func detect_collisions(turn) -> Vector3:
	var avoid_dict = {}
	var casts = {}
	casts.right = cast_collision_ray(transform.basis.x * RAY_OFFSET, -transform.basis.z)
	casts.left = cast_collision_ray(-transform.basis.x * RAY_OFFSET, -transform.basis.z)
	casts.up = cast_collision_ray(transform.basis.y * RAY_OFFSET, -transform.basis.z)
	casts.down = cast_collision_ray(-transform.basis.y * RAY_OFFSET, -transform.basis.z)
	var cast_ranks = {}
	if casts:
		if casts.right and casts.left:
			cast_ranks.right = cast_to_side(transform.basis.x, transform.basis.y, -deg2rad(45))
			cast_ranks.left = cast_to_side(-transform.basis.x, transform.basis.y, deg2rad(45))

			if cast_ranks.right <= cast_ranks.left:
				avoid_dict.y = turn
			else:
				avoid_dict.y = -turn
		elif casts.right:
			avoid_dict.y = turn
		elif casts.left:
			avoid_dict.y = -turn

		if casts.up and casts.down:
			cast_ranks.up = cast_to_side(transform.basis.y, transform.basis.x, deg2rad(45))
			cast_ranks.down = cast_to_side(-transform.basis.y, transform.basis.x, -deg2rad(45))

			if cast_ranks.up <= cast_ranks.down:
				avoid_dict.x = turn
			else:
				avoid_dict.x = -turn
		elif casts.up:
			avoid_dict.x = turn
		elif casts.down:
			avoid_dict.x = -turn

		if casts.right and casts.left and casts.up and casts.down:
			frames_trapped += 1
			frames_free = 0
		else:
			frames_free += 1
			if frames_free > 50:
				frames_trapped = 0
				frames_free = 0
		if frames_trapped > 20:
			avoid_dict.trapped = true
	
	return avoid_dict

func cast_to_side(side: Vector3, rotate_axis: Vector3, diagonal_angle: float) -> float:
	var hit_rank = 0
	var diagonal_cast = cast_collision_ray(
		side * RAY_OFFSET,
		(-transform.basis.z).rotated(rotate_axis, diagonal_angle),
		RAY_LENGTH / 2)
	if diagonal_cast:
		hit_rank += transform.origin.distance_squared_to(diagonal_cast.position)
		var side_cast = cast_collision_ray(
			side * RAY_OFFSET,
			side.rotated(rotate_axis, diagonal_angle),
			RAY_LENGTH / 2)
		if side_cast:
			hit_rank += transform.origin.distance_squared_to(side_cast.position)
	return hit_rank
	
func cast_collision_ray(offset: Vector3, direction: Vector3, length: float = RAY_LENGTH):
	var start = global_transform.origin + offset
	var end = start + direction * length
	LineDrawer.add_line(start, end)
	return get_world().direct_space_state.intersect_ray(start, end, [], 1)

# Smoothly turn to face player
func face_target(turn_speed, delta):
	var target_rotation = transform.looking_at(player.translation, Vector3.UP)
	transform = transform.interpolate_with(target_rotation, delta * turn_speed)

func alert_player_moved():
	has_player_moved = true

func _on_timeout():
	if is_idle:
		end_idle()
		return

func end_idle():
	is_idle = false

func die():
	queue_free()
	Global.on_enemy_die()

