extends KinematicBody

export var MAX_VELOCITY = 50
export var ACCELERATION = 0.025
export var DRAG = 0.025
export var MOUSE_SENSITIVITY = 0.1
export var MAX_VERTICLE_LOOK_ANGLE = 30
export var BASE_LOOK_ANGLE = -25
export var STRAFE_TILT_ANGLE = 10
export var CAMERA_LAG = 0.01
export var CAMERA_LAG_RATIOS = Vector3(1.5, 0.5, 1)

onready var player_attack_scn = preload("res://scenes/player/player_attack.tscn")

onready var camera = get_node('Camera')
onready var mesh = $Mesh

var velocity = Vector3.ZERO
var camera_offset
var player_attack

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_offset = camera.translation
	$AttackTimer.wait_time = 1.5
	$AttackTimer.connect("timeout", self, "_on_attack_timeout")

func _input(event):
	if event is InputEventMouseMotion:
		var movement = event.relative
		camera.rotation.x += -deg2rad(movement.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg2rad(BASE_LOOK_ANGLE - MAX_VERTICLE_LOOK_ANGLE),
			deg2rad(BASE_LOOK_ANGLE + MAX_VERTICLE_LOOK_ANGLE))
		rotation.y += -deg2rad(movement.x * MOUSE_SENSITIVITY)

func _physics_process(delta):
	var input_velocity = Vector3.ZERO

	if Input.is_action_pressed('left'):
		input_velocity.x -= 1
	if Input.is_action_pressed('right'):
		input_velocity.x += 1
	if Input.is_action_pressed('forward'):
		input_velocity.z -= 1
	if Input.is_action_pressed('back'):
		input_velocity.z += 1
	if Input.is_action_pressed('down'):
		input_velocity.y -= 1
	if Input.is_action_pressed('up'):
		input_velocity.y += 1
	if Input.is_action_pressed('attack') and !player_attack:
		print('attacked')
		player_attack = preload("res://scenes/player/player_attack.tscn").instance()
		player_attack.connect("body_entered", self, "_on_entity_hit")
		add_child(player_attack)
		player_attack.translation.z -= 3
		$AttackTimer.start()

	input_velocity = input_velocity \
		.normalized() \
		.rotated(Vector3.UP, rotation.y) \
		* MAX_VELOCITY
	
	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, ACCELERATION)
	else:
		velocity = velocity.linear_interpolate(Vector3.ZERO, DRAG)
	
	var rotated_velocity = velocity.rotated(Vector3.UP, -rotation.y)

	mesh.rotation.z = -rotated_velocity.x \
			/ MAX_VELOCITY \
			* deg2rad(STRAFE_TILT_ANGLE)

	velocity = move_and_slide(velocity)

	var camera_lag = rotated_velocity * CAMERA_LAG * CAMERA_LAG_RATIOS
	camera.translation = camera_offset - camera_lag

	#camera.translation = translation + camera_offset
	#camera.rotation.y = rotation.y

	#print(velocity)

func _on_attack_timeout():
	player_attack.free()
	player_attack = null

func _on_entity_hit(body):
	print('entity hit')
	if body.is_in_group("enemies"):
		print("enemy hit")
		body.damage(velocity)

