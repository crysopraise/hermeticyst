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
var TRAPPED_FRAMES = 75
var FREE_FRAMES = 50
var AVOID_ROTATION = deg2rad(90)
var REVERSE_SPEED_MOD = -0.5


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
var strafe_dir = 1
var target

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_G:
			die()

func _ready():
	ARGRO_RANGE_SQUARED = AGRO_RANGE*AGRO_RANGE
	
	if player and LOOK_AT_PLAYER:
		look_at(player.translation, Vector3.UP)
		target = player
	
	connect("enemy_die", LevelManager, "on_enemy_die")

func _physics_process(delta):
#	DebugOutput.add_output(name + ": " + ("idle" if is_idle else "active"))
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
	var turn = AVOID_ROTATION * delta
	var avoid_dict = detect_collisions(transform.basis)
	if avoid_dict:
		if avoid_dict.has('trapped'):
			target_velocity *= REVERSE_SPEED_MOD
			rotate_object_local(transform.basis.y, turn)
		else:
			if avoid_dict.has('y'):
				rotate_object_local(transform.basis.y, avoid_dict.y * turn)
			if avoid_dict.has('x'):
				rotate_object_local(transform.basis.x, avoid_dict.x * turn)
	else:
		face_target(turn_speed, delta)
	
	return target_velocity

func navigate_while_strafing(delta: float, target_velocity: Vector3, turn_speed: float = TURN_SPEED) -> Vector3:
	var turn = AVOID_ROTATION * delta
	var avoid_dict = detect_collisions(transform.basis.rotated(transform.basis.y, PI/2 * -strafe_dir))
	if avoid_dict:
		if avoid_dict.has('trapped'):
			strafe_dir = -strafe_dir
		else:
			if avoid_dict.has('y'):
				rotate_object_local(transform.basis.y, avoid_dict.y * turn)
			if avoid_dict.has('x'):
				rotate_object_local(transform.basis.x, avoid_dict.x * turn)
	face_target(turn_speed, delta)
	
	return target_velocity

func detect_collisions(direction: Basis) -> Vector3:
	var avoid_dict = {}
	var right_cast = cast_collision_ray(direction.x * RAY_OFFSET, -direction.z)
	var left_cast = cast_collision_ray(-direction.x * RAY_OFFSET, -direction.z)
	var up_cast = cast_collision_ray(direction.y * RAY_OFFSET, -direction.z)
	var down_cast = cast_collision_ray(-direction.y * RAY_OFFSET, -direction.z)
	LineDrawer.add_line(transform.origin + direction.x, transform.origin + direction.x + (-direction.z * RAY_LENGTH), Color(1, 0, 0))
	LineDrawer.add_line(transform.origin - direction.x, transform.origin - direction.x + (-direction.z * RAY_LENGTH), Color(0, 0, 1))
	LineDrawer.add_line(transform.origin + direction.y, transform.origin + direction.y + (-direction.z * RAY_LENGTH), Color(1, 1, 0))
	LineDrawer.add_line(transform.origin - direction.y, transform.origin - direction.y + (-direction.z * RAY_LENGTH), Color(0, 1, 0))
	var cast_ranks = {}
	if right_cast || left_cast || up_cast || down_cast:
		if right_cast and left_cast:
			var right_rank = cast_to_side(direction.x, direction.y, -deg2rad(45))
			var left_rank = cast_to_side(-direction.x, direction.y, deg2rad(45))
			
			if right_rank <= left_rank:
				avoid_dict.y = 1
			else:
				avoid_dict.y = -1
		elif right_cast:
			avoid_dict.y = 1
		elif left_cast:
			avoid_dict.y = -1
		
		if up_cast and down_cast:
			var up_rank = cast_to_side(direction.y, direction.x, deg2rad(45))
			var down_rank = cast_to_side(-direction.y, direction.x, -deg2rad(45))
			
			if up_rank <= down_rank:
				avoid_dict.x = 1
			else:
				avoid_dict.x = -1
		elif up_cast:
			avoid_dict.x = 1
		elif down_cast:
			avoid_dict.x = -1
		
		if right_cast and left_cast and up_cast and down_cast:
			frames_trapped += 1
			frames_free = 0
		if frames_trapped > TRAPPED_FRAMES:
			avoid_dict.trapped = true
	if frames_trapped > 0:
		frames_free += 1
		if frames_free > FREE_FRAMES:
			frames_trapped = 0
	
	# DebugOutput.add_output(["frames_trapped: ", frames_trapped, " frames_free: ", frames_free, " trapped: ", avoid_dict.get("trapped", "false")])
	
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
	var start = ($CastPoint.global_transform.origin if get_node_or_null('CastPoint') else global_transform.origin) + offset
	var end = start + direction * length
#	LineDrawer.add_line(start, end)
	return get_world().direct_space_state.intersect_ray(start, end, [], 1, true, true)

func get_player_dot():
	return translation.direction_to(player.translation).dot(-transform.basis.z)

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

func random_direction():
	return Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized()

func die(is_beam = false):
	is_dead = true
	if animation_player:
		animation_player.stop()
		animation_player.play('RESET')
	var skeleton = get_node_or_null('Model/Armature/Skeleton')
	if skeleton:
		skeleton.physical_bones_start_simulation()
		var children = skeleton.get_children()
		for child in children:
			print(child.name)
		print('Physical Bone ' + PHYSICS_BONE)
		if PHYSICS_BONE:
			var direction = random_direction()
			skeleton.get_node('Physical Bone ' + PHYSICS_BONE).apply_central_impulse(direction * 30)
	else:
		visible = false
	$Body.disabled = true
	var halo = get_node_or_null('Halo')
	if halo:
		halo.visible = false
	var blood_explosion = preload("res://scenes/player/blood_explosion.tscn").instance()
	get_tree().current_scene.add_child(blood_explosion)
	blood_explosion.transform = transform
	if get_node_or_null("Timer"):
		$Timer.stop()
	emit_signal("enemy_die")

