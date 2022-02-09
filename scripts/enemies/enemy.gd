extends KinematicBody

# Signals
signal enemy_die

# Constants
export var SPEED: float = 20
export var ACCELERATION: float = 0.05
export var TURN_SPEED: float = 4
export var AGRO_DELAY: float = 0
export var AGRO_RANGE: int = 100
export var RAY_OFFSET: float = 3
export var RAY_LENGTH: float = 10
export var ATTACK_TIME = 0.3
export var COOLDOWN_TIME = 0.5
export var LOOK_AT_PLAYER = true
export var EXTRA_LIFE = 0.34
export var PHYSICS_BONE = ''

# Animation constants
export var ANIM_PREFIX = ''
export var ATTACK_ANIM_SPEED = 1.0

var ARGRO_RANGE_SQUARED
var TRAPPED_FRAMES = 20
var FREE_FRAMES = 50
var AVOID_ROTATION = deg2rad(90)
var REVERSE_SPEED = -0.5


# Nodes
onready var player = get_tree().current_scene.get_node_or_null('Player')
onready var animation_player = get_node_or_null('Model/AnimationPlayer')

# Variables
var velocity = Vector3.ZERO
var has_player_moved = false
var is_idle = true
var is_dead = false
export var is_attacking = false
var on_cooldown = false
var frames_trapped = 0
var frames_free = 0
var target
var cast_origin

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_G:
			die()

func _ready():
	ARGRO_RANGE_SQUARED = AGRO_RANGE*AGRO_RANGE

	if player and LOOK_AT_PLAYER:
		look_at(player.translation, Vector3.UP)
		target = player

	var cast_point = get_node_or_null('CastPoint')
	cast_origin = cast_point.translation if cast_point else Vector3.ZERO

	connect("enemy_die", LevelManager, "on_enemy_die")

func _physics_process(delta):
	if is_idle:
		if player and has_player_moved and $Timer.is_stopped() and transform.origin.distance_squared_to(player.transform.origin) < ARGRO_RANGE_SQUARED:
			var sight_cast = get_world().direct_space_state.intersect_ray(transform.origin, player.transform.origin, [], 1)
			if !sight_cast:
				if AGRO_DELAY:
					$Timer.start(AGRO_DELAY)
				else:
					end_idle()
	elif is_dead:
		pass # Do nothing
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
	var right_cast = cast_collision_ray(transform.basis.x * RAY_OFFSET, -transform.basis.z)
	var left_cast = cast_collision_ray(-transform.basis.x * RAY_OFFSET, -transform.basis.z)
	var up_cast = cast_collision_ray(transform.basis.y * RAY_OFFSET, -transform.basis.z)
	var down_cast = cast_collision_ray(-transform.basis.y * RAY_OFFSET, -transform.basis.z)
	var cast_ranks = {}
	if right_cast || left_cast || up_cast || down_cast:
		if right_cast and left_cast:
			var right_rank = cast_to_side(transform.basis.x, transform.basis.y, -deg2rad(45))
			var left_rank = cast_to_side(-transform.basis.x, transform.basis.y, deg2rad(45))

			if right_rank <= left_rank:
				avoid_dict.y = turn
			else:
				avoid_dict.y = -turn
		elif right_cast:
			avoid_dict.y = turn
		elif left_cast:
			avoid_dict.y = -turn

		if up_cast and down_cast:
			var up_rank = cast_to_side(transform.basis.y, transform.basis.x, deg2rad(45))
			var down_rank = cast_to_side(-transform.basis.y, transform.basis.x, -deg2rad(45))

			if up_rank <= down_rank:
				avoid_dict.x = turn
			else:
				avoid_dict.x = -turn
		elif up_cast:
			avoid_dict.x = turn
		elif down_cast:
			avoid_dict.x = -turn

		if right_cast and left_cast and up_cast and down_cast:
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
	var start = global_transform.origin + cast_origin + offset
	var end = start + direction * length
	LineDrawer.add_line(start, end)
	return get_world().direct_space_state.intersect_ray(start, end, [], 1, true, true)

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

func die(is_beam = false):
	is_dead = true
	if animation_player:
		animation_player.stop()
		animation_player.play('RESET')
	var skeleton = get_node_or_null('Model/Armature/Skeleton')
	if skeleton:
		skeleton.physical_bones_start_simulation()
		if PHYSICS_BONE:
			var direction = Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized()
			skeleton.get_node('Physical Bone ' + PHYSICS_BONE).apply_central_impulse(direction * 30)
	else:
		visible = false
	$Body.disabled = true
	var halo = get_node_or_null('Halo')
	if halo:
		halo.visible = false
	emit_signal("enemy_die")

