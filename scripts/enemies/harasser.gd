extends "res://scripts/enemies/enemy.gd"

export var BULLET_SPEED = 20
export var BULLET_SIZE = 0.5
export var MIN_DISTANCE = 10
export var MAX_DISTANCE = 40

var DIRECTION_COUNT = 6

# Variables
var distance_mod = 1
var strafe_direction = Vector3.RIGHT
var z_rotation = 0
var direction_counter = 0

func _ready():
	._ready()
	change_direction()
	BulletManager.create_pool(name, 'bullet')

func end_idle():
	.end_idle()
	$Timer.start(COOLDOWN_TIME)

func active_state(delta):
	face_target(TURN_SPEED, delta)
	# Smoothly rotate to new z axis
	if z_rotation != rotation.z:
		rotate(transform.basis.z.normalized(), (z_rotation - rotation.z) * delta)

	# Change strafe direction based on where the player is looking
	var distance_to_player = translation.distance_to(player.translation)
	var direction_to_enemy = player.translation.direction_to(translation)
	var z_dot_product = direction_to_enemy.dot(-player.transform.basis.z)
	if z_dot_product > 0:
		var x_dot_product = direction_to_enemy.dot(player.transform.basis.x)
		strafe_direction = transform.basis.x if x_dot_product < 0 else -transform.basis.x

	# Move forward if greater then minimum distance, otherwise don't move or move back to min distance
	var forward_direction = -transform.basis.z if distance_to_player > MIN_DISTANCE else \
			(Vector3.ZERO if distance_to_player == 0 else transform.basis.z)

	# Add directions
	var direction = (-transform.basis.z + strafe_direction).normalized()

	# Calculate distance modifier (reduce speed the closer to the player)
	distance_mod = clamp(
		distance_to_player,
		MIN_DISTANCE,
		MAX_DISTANCE) / MAX_DISTANCE

	# Move harasser
	velocity = move_and_slide(velocity + (direction * delta * SPEED * distance_mod))

func _on_timeout():
	._on_timeout()

	BulletManager.fire_bullet(name, {
		'position': translation,
		'direction': translation.direction_to(player.translation),
		'speed': BULLET_SPEED,
		'size': BULLET_SIZE,
		'is_destroyable': true
	})

	# Select a random rotation on the z-axis every 3 shots (this prevents enemies from staying in a single line)
	direction_counter += 1
	if direction_counter == DIRECTION_COUNT:
		change_direction()

func change_direction():
	z_rotation = rand_range(-TAU, TAU)
	direction_counter = 0

