extends "res://scripts/enemies/enemy.gd"

# Constants
export var MOVE_DISTANCE = 30.0
var MOVE_TIME : float

# Nodes
onready var bullet_spawner = $BulletSpawner

# Variables
var move_direction = Vector3.FORWARD
var is_moving = false

func _ready():
	._ready()
	MOVE_TIME = MOVE_DISTANCE / SPEED
	bullet_spawner.connect('attack_finished', self, '_on_timeout')

func end_idle():
	.end_idle()
	# On first run, start timing and switch to attack state
	_on_timeout()

func die(is_beam = false):
	.die()
	$BulletSpawner.stop_attack()

func active_state(delta):
	face_target(TURN_SPEED, delta)
	if is_moving:
		var target_velocity = move_direction * SPEED
		velocity = velocity.linear_interpolate(target_velocity, ACCELERATION)
		velocity = move_and_slide(velocity)

func start_move():
	var move_collision = true
	while move_collision:
		move_direction = get_random_direction()
		move_collision = cast_collision_ray(
			Vector3.ZERO,
			move_direction,
			MOVE_DISTANCE
		)
		is_moving = true
		$Timer.start(MOVE_TIME)

func get_random_direction():
	var x_rot = rand_range(0, TAU)
	var y_rot = rand_range(0, TAU)
	var z_rot = rand_range(0, TAU)

	return Vector3.FORWARD \
			.rotated(Vector3.RIGHT, x_rot) \
			.rotated(Vector3.UP, y_rot) \
			.rotated(Vector3.BACK, z_rot) \
			.normalized()

func _on_timeout():
	._on_timeout()
	if is_attacking:
		is_attacking = false
		start_move()
	else:
		if is_moving:
			is_moving = false
			$Timer.start(max(COOLDOWN_TIME - MOVE_TIME, 0.001))
		else:
			is_attacking = true
			$BulletSpawner.shoot()

