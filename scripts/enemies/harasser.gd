extends Spatial

export var SPEED = 20
export var TURN_SPEED = 4
export var BULLET_SPEED = 20
export var MIN_DISTANCE = 15
export var MAX_DISTANCE = 40

# Scenes
onready var bullet_scn = preload("res://scenes/enemies/simple_bullet.tscn")

# Nodes
onready var player = get_tree().current_scene.get_node('Player')

# Variables
var distance_mod = 1
var z_rotation = 0
var strafe_direction = Vector3.RIGHT

func _ready():
	# Face player and set a random direction
	look_at(Vector3.UP, player.translation)
	change_direction()
	print(get_parent())

func _physics_process(delta):
	# Smoothly turn to face player
	var target_rotation = transform.looking_at(player.translation, Vector3.UP)
	transform = transform.interpolate_with(target_rotation, delta * TURN_SPEED)
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

func _on_shoot():
	# Shoot bullet toward player
	var bullet = bullet_scn.instance()
	bullet.move_forward = true
	bullet.speed = BULLET_SPEED
	get_tree().current_scene.add_child(bullet)
	bullet.translation = translation
	bullet.look_at(player.translation, Vector3.UP)

func change_direction():
	# Select a random rotation on the z-axis (this prevents enemies from staying in a single line)
	z_rotation = rand_range(-TAU, TAU)

