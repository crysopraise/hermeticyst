extends Spatial

export var SPEED = 20
export var TURN_SPEED = 4
export var BULLET_SPEED = 20
export var MIN_DISTANCE = 15
export var MAX_DISTANCE = 40

onready var bullet_scn = preload("res://scenes/enemies/simple_bullet.tscn")

onready var player = get_tree().current_scene.get_node('Player')

var distance_mod = 1
var z_rotation = 0

func _ready():
	look_at(Vector3.UP, player.translation)

func _physics_process(delta):
	var target_rotation = transform.looking_at(player.translation, Vector3.UP)
	transform = transform.interpolate_with(target_rotation, delta * TURN_SPEED)
	rotate(transform.basis.z.normalized(), (z_rotation - rotation.z) * delta)

	var distance_to_player = translation.distance_to(player.translation)

	var direction = Vector3.ZERO
	distance_mod = clamp(
		distance_to_player,
		MIN_DISTANCE,
		MAX_DISTANCE) / MAX_DISTANCE

	var direction_to_enemy = player.translation.direction_to(translation)
	var dot_product = direction_to_enemy.dot(player.transform.basis.x)
	var strafe_direction = Vector3.RIGHT if dot_product < 0 else Vector3.LEFT	
	direction = (direction + 
		(Vector3.FORWARD if distance_to_player > MIN_DISTANCE else Vector3.ZERO) +
		strafe_direction).normalized()

	translate(direction * delta * SPEED * distance_mod)

func _on_shoot():
	var bullet = bullet_scn.instance()
	bullet.move_forward = true
	bullet.speed = BULLET_SPEED
	get_tree().root.add_child(bullet)
	bullet.translation = translation
	bullet.look_at(player.translation, Vector3.UP)

func _on_direction_change():
	z_rotation = rand_range(-TAU, TAU)
	print(z_rotation)

