extends KinematicBody

export var TURN_SPEED = 2
export var BULLET_SPEED = 7.5
export var X_ROTATE_INC = 20
export var Z_ROTATE_INC = 20
export var BULLET_RINGS = 4
export var BULLET_COUNT = 4

onready var bullet_scn = preload("res://scenes/enemies/simple_bullet.tscn")
onready var player = get_node("../Player")

var is_shooting = false
var bullet_rotation = 0

func _ready():
	pass

func _process(delta):
	if is_shooting:
		pass
	else:
		var target_rotation = transform.looking_at(player.transform.origin, Vector3.UP)
		transform = transform.interpolate_with(target_rotation, delta * TURN_SPEED)

func _on_shoot():
	for i in range(BULLET_RINGS):
		for j in range(BULLET_COUNT):
			var bullet = bullet_scn.instance()
			bullet.move_forward = true
			bullet.speed = BULLET_SPEED
			get_tree().root.add_child(bullet)
			bullet.transform.origin = $SpawnPoint.global_transform.origin
			bullet.transform.basis = transform.basis
			bullet.rotate_x(deg2rad(i * X_ROTATE_INC))
			bullet.rotate(
				transform.basis.z,
				deg2rad(bullet_rotation + (j * (360 / BULLET_COUNT))))
	bullet_rotation += Z_ROTATE_INC

func _on_attack_end():
	$ShootTimer.stop()
	$CooldownTimer.start()
	is_shooting = false

func _on_cooldown_end():
	$AttackTimer.start()
	$ShootTimer.start()
	is_shooting = true

