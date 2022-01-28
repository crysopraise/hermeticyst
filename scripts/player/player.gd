extends KinematicBody

# Signals
signal update_blood(current, total)
signal update_health(current)
signal update_velocity(velocity)
signal player_die

# Movement constants
export var VELOCITY = 10
export var ACCELERATION = 0.075
export var DRAG = 0.0
export var BOOST_VELOCITY = 40
export var BOOST_ACCELRATION = 0.15
export var BOOST_LENGTH = 0.4
export var ATTACK_VELOCITY = 15
export var STUNNED_DECELERATION = 0.03

# Combat constants
export var STUN_TIME = 1
export var INVINCIBLE_TIME = 2

# Mouse/look constants
export var MOUSE_SENSITIVITY = 0.1
export var MAX_VERTICLE_LOOK_ANGLE = 60
export var BASE_LOOK_ANGLE = 0

# Model Tilt and Camera lag constants
export var STRAFE_TILT_ANGLE = 5
export var STRAFE_Y_ROTATION = 10
export var CAMERA_LAG = 0.01
export var CAMERA_LAG_RATIOS = Vector3(8, 3, 4)

# Blood constants
export var BASE_BLOOD_TOTAL = 100
export var BASE_BLOOD_REGEN = 5 # per second
export var BOOST_BLOOD_COST = 10
export var ATTACK_BLOOD_COST = 15
# Unused atm
var BASE_BOOST_SPEED_MODIFIER = 4
var BASE_BOOST_ACCEL_MODIFIER = 7.5
var BASE_BOOST_MAX_VEL_MODIFIER = 1.5

# Blood value constants
export var TOTAL_INCREASE_RATIO = 20
export var REGEN_INCREASE_RATIO = 1
export var SPEED_INCREASE_RATIO = 0

# Animation constants
export var ATTACK_ANIM_SPEED = 1.5
export var ATTACK_ANIM_DURATION = 1.0
var ATTACK_ANIM_NAME = 'player_idleattack01'
var ATTACK_ANIM_NAME_2 ='player_idleattack02' 

# Other
var HEALTH_MAX = 3
var SAFE_DISTANCE = 3
var SAFE_DISTANCE_SQUARED = SAFE_DISTANCE*SAFE_DISTANCE

# Scenes
onready var player_attack_scn = preload("res://scenes/player/player_attack.tscn")

# Shader
onready var invincible_shader = preload("res://shaders/player_invincible.tres")

# Nodes
onready var camera = $Pivot
onready var model = $Model
onready var animation_player = $Model/AnimationPlayer

# Variables
var velocity = Vector3.ZERO
var boost_direction = Vector3.ZERO
var blood = BASE_BLOOD_TOTAL
var has_moved = false
var is_boosting = false
export var is_attacking = false
var is_invincible = false
var is_stunned = false
var is_dead = false
var health = 2
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

	# Connect global events
	connect("player_die", LevelManager, "on_player_die")

	# Connect player to GUI
#	var gui = get_parent().get_node_or_null('GUI') 
#	if gui:
#		connect("update_blood", gui, "update_blood")

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
	# Disable movment/input if dead
	if is_dead:
		velocity = velocity.linear_interpolate(Vector3.ZERO, ACCELERATION)
		velocity = move_and_slide(velocity)
		return
	
	
	# Input
	
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
		and !is_attacking and !is_stunned:
		if animation_player.current_animation == ATTACK_ANIM_NAME:
			# animation_player.seek(0)
			animation_player.play(ATTACK_ANIM_NAME_2, 0.1)
		elif animation_player.current_animation == ATTACK_ANIM_NAME_2:
			animation_player.play(ATTACK_ANIM_NAME, 0.1, ATTACK_ANIM_SPEED)
		else:
			animation_player.play(ATTACK_ANIM_NAME, 0.1, ATTACK_ANIM_SPEED)
	if Input.is_action_pressed('boost') and !is_boosting \
			and blood > 0 and !is_stunned and input_direction.length():
		boost_direction = input_direction
		is_boosting = true
		blood -= BOOST_BLOOD_COST
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
		LevelManager.reset_level()
	
	
	# Movement
	
	# Get the maximum velocity (scalar)
	var max_velocity = BOOST_VELOCITY if is_boosting else VELOCITY
	
	# Multiply directional input by velocity
	#var target_velocity = (boost_direction if is_boosting else input_direction) \
	#		* max_velocity
	var target_velocity = input_direction * VELOCITY + (boost_direction * BOOST_VELOCITY if is_boosting else Vector3.ZERO)
	
	if (input_direction.length() > 0 or boost_direction.length() > 0) and !is_stunned:
		# Accelerate towards target velocity if there is input
		var acceleration = BOOST_ACCELRATION if is_boosting else ACCELERATION
		velocity = velocity.linear_interpolate(target_velocity, acceleration)
	elif is_stunned:
		velocity = velocity.linear_interpolate(Vector3.ZERO, STUNNED_DECELERATION)
	else:
		# Decelerate if there is no input
		velocity = velocity.linear_interpolate(Vector3.ZERO, ACCELERATION)
	
	# Move character
	velocity = move_and_slide(velocity)
	
	# Set enemies to attack state
	if velocity.length() and !has_moved:
		LevelManager.agro_enemies()
		has_moved = true
	
	# Camera and Model updates
	
	var rotated_velocity = velocity.rotated(Vector3.UP, -rotation.y).rotated(Vector3.RIGHT, -camera.rotation.x)
	
	# Play movement animation
	if (animation_player.current_animation != ATTACK_ANIM_NAME \
			and animation_player.current_animation != ATTACK_ANIM_NAME_2) \
			or animation_player.current_animation_position > ATTACK_ANIM_DURATION:
		if is_boosting and (rotated_velocity.z < 0 or abs(rotated_velocity.x) > VELOCITY):
			animation_player.play('player_dash', 0.25)
		else:
			animation_player.play('player_idle', 0.25)
	
	# Rotate model according to velocity
	model.rotation.z = -rotated_velocity.x \
			/ VELOCITY \
			* deg2rad(STRAFE_TILT_ANGLE)
	model.rotation.x = camera.rotation.x + rotated_velocity.z \
			/ VELOCITY \
			* deg2rad(STRAFE_TILT_ANGLE)
	model.rotation.y = -rotated_velocity.x / VELOCITY * deg2rad(STRAFE_Y_ROTATION)

	# Align player with camera after attacking
	if !is_instance_valid(player_attack) and camera.rotation.y != 0:
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
	emit_signal("update_health", health)

	# Debug output
	DebugOutput.add_output(velocity.length())
#	DebugOutput.add_output(animation_player.current_animation)
#	DebugOutput.add_output('is attacking: ' + str(is_attacking))
#	DebugOutput.add_output('is stunned: ' + str(is_stunned))
	DebugOutput.add_output('health: ' + str(health))
	DebugOutput.add_output('invincible: ' + str(is_invincible))

func knock_back(speed, direction):
	velocity = direction * speed
	is_stunned = true
	is_boosting = false
	$Timer.start(STUN_TIME)

func _on_hit(col):
	# Collide with enemy layer
	if col.collision_layer & 4 or (col.collision_layer & 64 and col.get('is_destroyable')):
		col.call_deferred('die')
		health = min(health + 1, HEALTH_MAX)
		return
	# Collide with cyst layer
	if col.collision_layer & 8:
		var entity = col.get_parent()
		_increase_blood(entity.blood_value)
		entity.queue_free()
		return

func die(damage = 1):
	if is_dead || is_invincible:
		return
	health -= damage
	if health > 0:
		is_invincible = true
		$Timer.start(INVINCIBLE_TIME)
		$Model/Armature/Skeleton/playermodel.material_override = invincible_shader
	else:
		is_dead = true
		$Model/Armature/Skeleton.physical_bones_start_simulation()
		emit_signal("player_die")

func _increase_blood(blood_value):
	blood_total_modifier += blood_value * TOTAL_INCREASE_RATIO
	blood_regen_modifier += blood_value * REGEN_INCREASE_RATIO
	# boost_speed_modifier += blood_value * SPEED_INCREASE_RATIO

	blood = BASE_BLOOD_TOTAL + blood_total_modifier

	# Update blood bar total
	emit_signal("update_blood", blood, BASE_BLOOD_TOTAL + blood_total_modifier)

func _attack_boost():
	velocity += Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * ATTACK_VELOCITY

func _on_timeout():
	if is_invincible:
		is_invincible = false
		$Model/Armature/Skeleton/playermodel.material_override = null
	if is_stunned:
		is_stunned = false
