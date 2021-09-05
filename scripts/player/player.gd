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

# Blood constants
export var BASE_BLOOD_TOTAL = 50
export var BASE_BLOOD_REGEN = 5 # per second
export var BOOST_BLOOD_COST = 20 # per second
export var BASE_BOOST_SPEED_MODIFIER = 1.5
#export var BASE_BOOST_MAX_VEL_MODIFIER = 1.5

# Blood value constants
export var TOTAL_RATIO = 10
export var REGEN_RATIO = 1
export var SPEED_RATIO = 0.2

onready var player_attack_scn = preload("res://scenes/player/player_attack.tscn")

onready var camera = get_node('Camera')
onready var mesh = $Mesh
onready var blood_remaining_bar = $HealthBar/Remaining
onready var blood_total_bar = $HealthBar/Total

var velocity = Vector3.ZERO
var blood = BASE_BLOOD_TOTAL
var blood_total_modifier = 0
var blood_regen_modifier = 0
var blood_speed_modifier = 1
var boost_speed_modifier = BASE_BOOST_SPEED_MODIFIER
#var boost_vel_modifier = BASE_BOOST_MAX_VEL_MODIFIER
var camera_offset
var player_attack

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_offset = camera.translation
	$AttackTimer.wait_time = 1.5
	$AttackTimer.connect("timeout", self, "_on_attack_timeout")
	blood_total_bar.rect_scale.x = BASE_BLOOD_TOTAL / 100.0

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
	var is_boosting = false

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
	if Input.is_action_pressed('boost') and blood > 0:
		is_boosting = true
		blood -= BOOST_BLOOD_COST * delta
	else:
		var regen = (BASE_BLOOD_REGEN + blood_regen_modifier) * delta
		blood = min(blood + regen, BASE_BLOOD_TOTAL + blood_total_modifier)
		#print(regen)

	var max_velocity = MAX_VELOCITY * boost_speed_modifier \
			if is_boosting else MAX_VELOCITY * blood_speed_modifier
	
	input_velocity = input_velocity \
		.normalized() \
		.rotated(Vector3.UP, rotation.y) \
		* max_velocity
	
	if input_velocity.length() > 0:
		var accelaration = ACCELERATION * boost_speed_modifier \
				if is_boosting else ACCELERATION * blood_speed_modifier
		velocity = velocity.linear_interpolate(input_velocity, accelaration)
	else:
		velocity = velocity.linear_interpolate(Vector3.ZERO, DRAG)
	
	var rotated_velocity = velocity.rotated(Vector3.UP, -rotation.y)

	mesh.rotation.z = -rotated_velocity.x \
			/ MAX_VELOCITY \
			* deg2rad(STRAFE_TILT_ANGLE)

	velocity = move_and_slide(velocity)

	var camera_lag = rotated_velocity * CAMERA_LAG * CAMERA_LAG_RATIOS
	camera.translation = camera_offset - camera_lag

	blood_remaining_bar.rect_scale.x = blood / 100

	# Debug output
	$VelocityDebug.text = str(velocity.length())

	#camera.translation = translation + camera_offset
	#camera.rotation.y = rotation.y

	#print(velocity)

func _on_attack_timeout():
	player_attack.free()
	player_attack = null

func _on_entity_hit(body):
	if body.is_in_group("enemies"):
		print("enemy hit")
		body.damage(velocity)
	if body.is_in_group("cysts"):
		_increase_blood(body.blood_value)
		body.queue_free()

func _increase_blood(blood_value):
	blood_total_modifier += blood_value * TOTAL_RATIO
	blood_regen_modifier += blood_value * REGEN_RATIO
	boost_speed_modifier += blood_value * SPEED_RATIO

	var blood_total = BASE_BLOOD_TOTAL + blood_total_modifier
	blood = blood_total
	blood_total_bar.rect_scale.x = blood_total / 100.0

