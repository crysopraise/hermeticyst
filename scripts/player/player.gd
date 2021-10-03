extends KinematicBody

# Signals
signal update_blood(current, total)
signal update_velocity(velocity)

# Movement constants
export var VELOCITY = 7.5
export var ACCELERATION = 0.020
export var DRAG = 0.02
export var BOOST_VELOCITY = 25
export var BOOST_ACCELRATION = 0.15
export var BOOST_LENGTH = 0.4
export var ATTACK_VELOCITY = 15

# Combat constants
export var ATTACK_TIME = 0.4
export var COOLDOWN_TIME = 0.3
export var STUN_TIME = 0.25

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
export var BOOST_BLOOD_COST = 10
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
#onready var animation = $Model/AnimationPlayer

# Variables
var velocity = Vector3.ZERO
var boost_direction = Vector3.ZERO
var blood = BASE_BLOOD_TOTAL
var has_moved = false
var is_boosting = false
var is_attacking = false
var on_cooldown = false
var is_stunned = false
var is_dead = false
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

	#$BoostTimer.wait_time = BOOST_LENGTH

	# Connect player to GUI
	var gui = get_parent().get_node_or_null('GUI') 
	if gui:
		connect("update_blood", gui, "update_blood")
		connect("update_velocity", gui, "update_velocity")

func _input(event):
	# Rotate camera and player when mouse moves
	if event is InputEventMouseMotion and !is_dead:
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
	if is_dead:
		velocity = velocity.linear_interpolate(Vector3.ZERO, ACCELERATION)
		velocity = move_and_slide(velocity)
		return

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
	if Input.is_action_just_pressed('attack') \
		and !player_attack and !on_cooldown and !is_stunned \
		and Global.enemy_count > 0:
		player_attack = player_attack_scn.instance()
		player_attack.get_node('Hitbox').connect('area_entered', self, '_on_entity_hit')
		add_child(player_attack)
		player_attack.transform.basis = camera.transform.basis
		$AttackTimer.wait_time = ATTACK_TIME
		$AttackTimer.start()
	if Input.is_action_pressed('boost') and !is_boosting \
			and blood > 0 and !is_stunned and input_direction.length():
		boost_direction = input_direction
		is_boosting = true
		blood -= BOOST_BLOOD_COST
		#$BoostTimer.start()
	if Input.is_action_just_released('boost'):
		is_boosting = false
	
	# Deplete/regen blood
	if !is_boosting:
		var regen = (BASE_BLOOD_REGEN + blood_regen_modifier) * delta
		blood = min(blood + regen, BASE_BLOOD_TOTAL + blood_total_modifier)
	
	# Debug
	if Input.is_action_just_pressed('debug_button'):
		blood = BASE_BLOOD_TOTAL
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

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

	# Set enemies to attack state
	if velocity.length() and !has_moved:
		get_tree().call_group('enemies', 'end_idle')
		has_moved = true

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
	emit_signal("update_blood", blood, BASE_BLOOD_TOTAL + blood_total_modifier)

	# Debug output
	emit_signal("update_velocity", velocity)

func knock_back(speed):
	velocity = transform.basis.z * speed
	is_stunned = true
	is_boosting = false

func _on_entity_hit(area):
	# Collide with enemy layer
	if area.get_collision_layer_bit(2):
		area.get_parent().call_deferred('die')
		return
	# Collide with cyst layer
	if area.get_collision_layer_bit(3):
		var entity = area.get_parent()
		_increase_blood(entity.blood_value)
		entity.queue_free()
		return

func _increase_blood(blood_value):
	blood_total_modifier += blood_value * TOTAL_INCREASE_RATIO
	blood_regen_modifier += blood_value * REGEN_INCREASE_RATIO
	# boost_speed_modifier += blood_value * SPEED_INCREASE_RATIO

	# Update blood bar total
	emit_signal("update_blood", blood, BASE_BLOOD_TOTAL + blood_total_modifier)

func _attack_boost():
	velocity += Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * ATTACK_VELOCITY

func _attack_end():
	#animation.play("Idle", 0.5)
	#is_attacking = false
	if player_attack:
		player_attack.queue_free()
		on_cooldown = true
		$AttackTimer.wait_time = STUN_TIME if is_stunned else COOLDOWN_TIME
		$AttackTimer.start()
		return
	if on_cooldown:
		on_cooldown = false
	if is_stunned:
		is_stunned = false

