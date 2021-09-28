extends "res://scripts/enemies/enemy_base.gd"

export var BULLET_SPEED = 20
export var MIN_DISTANCE = 15
export var MAX_DISTANCE = 40

# Scenes
onready var bullet_scn = preload("res://scenes/enemies/bullet_hell/simple_bullet.tscn")

# Variables
var distance_mod = 1
var strafe_direction = Vector3.RIGHT
var z_rotation = 0
var direction_counter = 0

func _ready():
	._ready()
	change_direction()

func end_idle():
	.end_idle()
	$Timer.start()
	$DirectionTimer.start()

func attack_state(delta):
	face_player(TURN_SPEED, delta)
	# Smoothly rotate to new z axis
	if z_rotation != rotation.z:
		rotate(transform.basis.z.normalized(), (z_rotation - rotation.z) * delta)

	# Change strafe direction based on where the player is looking
	var distance_to_player = translation.distance_to(player.translation)
	var direction_to_enemy = player.translation.direction_to(translation)
	var z_dot_product = direction_to_enemy.dot(-player.transform.basis.z)
	if z_dot_product > 0:
		var x_dot_product = direction_to_enemy.dot(player.transform.basis.x)
		strafe_direction = Vector3.RIGHT if x_dot_product < 0 else Vector3.LEFT	

	# Move forward if greater then minimum distance, otherwise don't move or move back to min distance
	var forward_direction = Vector3.FORWARD if distance_to_player > MIN_DISTANCE else \
			(Vector3.ZERO if distance_to_player == 0 else Vector3.BACK)

	# Add directions
	var direction = (forward_direction + strafe_direction).normalized()

	# Calculate distance modifier (reduce speed the closer to the player)
	distance_mod = clamp(
		distance_to_player,
		MIN_DISTANCE,
		MAX_DISTANCE) / MAX_DISTANCE

	# Move harasser
	translate(direction * delta * SPEED * distance_mod)

func _on_timeout():
	._on_timeout()

	# Shoot bullet toward player
	var bullet = bullet_scn.instance()
	bullet.move_forward = true
	bullet.speed = BULLET_SPEED
	get_tree().current_scene.add_child(bullet)
	bullet.translation = translation
	bullet.look_at(player.translation, Vector3.UP)

	# Select a random rotation on the z-axis every 3 shots (this prevents enemies from staying in a single line)
	direction_counter += 1
	if direction_counter == 3:
		z_rotation = rand_range(-TAU, TAU)
		direction_counter = 0

func change_direction():
	pass
