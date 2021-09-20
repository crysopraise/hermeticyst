extends KinematicBody

# Movement constants
export var VELOCITY = 5
export var ACCELERATION = 0.020
export var DRAG = 0.02
export var BOOST_VELOCITY = 25
export var BOOST_ACCELRATION = 0.15
export var BOOST_LENGTH = 0.4
export var ATTACK_VELOCITY = 15

# Mouse/look constants
export var MOUSE_SENSITIVITY = 0.1
export var MAX_VERTICLE_LOOK_ANGLE = 60
export var BASE_LOOK_ANGLE = 0

# Model Tilt and Camera lag constants
export var STRAFE_TILT_ANGLE = 5
export var CAMERA_LAG = 0.01
export var CAMERA_LAG_RATIOS = Vector3(8, 3, 4)

# Blood constants
export var BASE_BLOOD_TOTAL = 100
export var BASE_BLOOD_REGEN = 5 # per second
export var BOOST_BLOOD_COST = 30 # per second
export var ATTACK_BLOOD_COST = 15
# Unused atm
export var BASE_BOOST_SPEED_MODIFIER = 4
export var BASE_BOOST_ACCEL_MODIFIER = 7.5
export var BASE_BOOST_MAX_VEL_MODIFIER = 1.5

# Blood value constants
export var TOTAL_INCREASE_RATIO = 10
export var REGEN_INCREASE_RATIO = 1
export var SPEED_INCREASE_RATIO = 0

# Scenes
onready var player_attack_scn = preload("res://scenes/player/player_attack.tscn")

# Nodes
onready var camera = $Pivot
onready var model = $Model
onready var blood_remaining_bar = $HealthBar/Remaining
onready var blood_total_bar = $HealthBar/Total
#onready var animation = $Model/AnimationPlayer

# Variables
var velocity = Vector3.ZERO
var boost_direction = Vector3.ZERO
var blood = BASE_BLOOD_TOTAL
var is_boosting = false
var is_attacking = false
var camera_offset
var player_attack

var blood_total_modifier = 0
var blood_regen_modifier = 0

# Unused atm
var blood_speed_modifier = 1
var boost_speed_modifier = BASE_BOOST_SPEED_MODIFIER
var boost_accel_modifier = BASE_BOOST_ACCEL_MODIFIER
var boost_vel_modifier = BASE_BOOST_MAX_VEL_MODIFIER

func _ready():
	# Prevent mouse from going off screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Set the original camera offset for calculating camera lag
	camera_offset = camera.translation

	# Should do this in the editor lol
	$AttackTimer.wait_time = 1.5
	$AttackTimer.connect("timeout", self, "_on_attack_timeout")
	#$BoostTimer.wait_time = BOOST_LENGTH

	# Set blood bar size
	blood_total_bar.rect_scale.x = BASE_BLOOD_TOTAL / 100.0

func _input(event):
	# Rotate camera and player when mouse moves
	if event is InputEventMouseMotion:
		var movement = event.relative

		# Rotate camera up and down
		camera.rotation.x += -deg2rad(movement.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg2rad(BASE_LOOK_ANGLE - MAX_VERTICLE_LOOK_ANGLE),
			deg2rad(BASE_LOOK_ANGLE + MAX_VERTICLE_LOOK_ANGLE))

		# Rotate character left and right
		if player_attack:
			camera.rotation.y += -deg2rad(movement.x * MOUSE_SENSITIVITY)
		else:
			rotation.y += -deg2rad(movement.x * MOUSE_SENSITIVITY)

func _physics_process(delta):
	var input_direction = Vector3.ZERO
	var attack_velocity = Vector3.ZERO

	# Directional inputs
	# Use direction of camera to determine movement direction
	if Input.is_action_pressed('left'):
		input_direction -= camera.global_transform.basis.x
	if Input.is_action_pressed('right'):
		input_direction += camera.global_transform.basis.x
	if Input.is_action_pressed('forward'):
		input_direction -= camera.global_transform.basis.z
	if Input.is_action_pressed('back'):
		input_direction += camera.global_transform.basis.z
	if Input.is_action_pressed('down'):
		input_direction -= camera.global_transform.basis.y
	if Input.is_action_pressed('up'):
		input_direction += camera.global_transform.basis.y
	
	# Normalize input
	input_direction = input_direction.normalized()
	
	# Attack and boost
	if Input.is_action_just_pressed('attack') and !player_attack:
		player_attack = player_attack_scn.instance()
		player_attack.get_node('HitBox').connect('area_entered', self, '_on_entity_hit')
		add_child(player_attack)
		player_attack.transform.basis = camera.transform.basis
		$AttackTimer.start()
	if Input.is_action_just_pressed('boost') and blood > 0:
		boost_direction = input_direction
		is_boosting = true
		#$BoostTimer.start()
	if Input.is_action_just_released('boost'):
		is_boosting = false
	
	# Deplete/regen blood
	if is_boosting:
		blood -= BOOST_BLOOD_COST * delta
	else:
		is_boosting = false
		var regen = (BASE_BLOOD_REGEN + blood_regen_modifier) * delta
		blood = min(blood + regen, BASE_BLOOD_TOTAL + blood_total_modifier)
	
	# Debug
	if Input.is_action_just_pressed('debug_button'):
		blood = BASE_BLOOD_TOTAL

	# Get the maximum velocity (calar)
	var max_velocity = BOOST_VELOCITY if is_boosting else VELOCITY
	
	# Multiply directional input by velocity
	#var target_velocity = (boost_direction if is_boosting else input_direction) \
	#		* max_velocity
	var target_velocity = input_direction * VELOCITY + (boost_direction * BOOST_VELOCITY if is_boosting else Vector3.ZERO)
	
	if input_direction.length() > 0 or boost_direction.length() > 0:
		# Accelerate towards target velocity if there is input
		var acceleration = BOOST_ACCELRATION if is_boosting else ACCELERATION
		velocity = velocity.linear_interpolate(target_velocity, acceleration)
	else:
		# Decelerate if there is no input
		velocity = velocity.linear_interpolate(Vector3.ZERO, ACCELERATION)
	
	# Rotate model according to velocity
	var rotated_velocity = velocity.rotated(Vector3.UP, -rotation.y)
	model.rotation.z = -rotated_velocity.x \
			/ VELOCITY \
			* deg2rad(STRAFE_TILT_ANGLE)
	model.rotation.x = camera.rotation.x + rotated_velocity.z \
			/ VELOCITY \
			* deg2rad(STRAFE_TILT_ANGLE)

	# Move character
	velocity = move_and_slide(velocity)

	# Align player with camera after attacking
	if !player_attack and camera.rotation.y != 0:
		var rotation_delta = (0 - camera.rotation.y) * delta * 5
		rotation.y -= rotation_delta
		camera.rotation.y += rotation_delta
		if abs(camera.rotation.y) < 0.001:
			camera.rotation.y = 0

	# Add camera lag
	var camera_lag = rotated_velocity * CAMERA_LAG * CAMERA_LAG_RATIOS
	camera.translation = camera_offset - camera_lag

	# Update blood bar
	blood_remaining_bar.rect_scale.x = blood / 100

	# Debug output
	$VelocityDebug.text = str(velocity.length())

func _on_attack_timeout():
	player_attack.free()
	player_attack = null

func _on_entity_hit(entity):
	if entity.is_in_group("enemies"):
		entity.get_parent().queue_free()
	if entity.is_in_group("cysts"):
		_increase_blood(entity.blood_value)
		entity.queue_free()

func _increase_blood(blood_value):
	blood_total_modifier += blood_value * TOTAL_INCREASE_RATIO
	blood_regen_modifier += blood_value * REGEN_INCREASE_RATIO
	# boost_speed_modifier += blood_value * SPEED_INCREASE_RATIO

	# Update blood bar total
	var blood_total = BASE_BLOOD_TOTAL + blood_total_modifier
	blood = blood_total
	blood_total_bar.rect_scale.x = blood_total / 100.0

func _attack_boost():
	velocity += Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * ATTACK_VELOCITY

func _attack_end():
	#animation.play("Idle", 0.5)
	#is_attacking = false
	if player_attack:
		player_attack.queue_free()

func die():
	get_tree().reload_current_scene()

