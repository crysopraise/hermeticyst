extends KinematicBody

# Signals
signal update_blood(current, total)
signal update_life(current)
signal update_velocity(velocity)
signal player_die
signal activate_target
signal deactivate_target

# Movement constants
export var VELOCITY = 10
export var ACCELERATION = 0.075
export var BOOST_VELOCITY = 40
export var BOOST_ACCELERATION = 0.15
export var BOOST_KNOCKBACK_ACCELERATION = 20
export var STUNNED_DECELERATION = 0.03

# Combat constants
export var STUN_TIME = 1
export var INVINCIBLE_TIME = 2
export var BEAM_TIME : float = 1

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
export var BASE_BLOOD_REGEN = 7.5 # per second
export var BLOOD_REGEN_ACCELERATION = 10 # per second
export var BLOOD_REGEN_MODIFIER_MAX = 22.5
export var BOOST_BLOOD_COST = 10
export var ATTACK_BLOOD_COST = 7.5
export var BLOOD_REGEN_COOLDOWN = 0.5
export var BLOOD_REGEN_ZERO_COOLDOWN = 2
export var SPECIAL_BLOOD_RECOVER = 50

# Unused atm
var BASE_BOOST_SPEED_MODIFIER = 4
var BASE_BOOST_ACCEL_MODIFIER = 7.5
var BASE_BOOST_MAX_VEL_MODIFIER = 1.5

# Blood value constants
var TOTAL_INCREASE_RATIO = 20
var REGEN_INCREASE_RATIO = 1
var SPEED_INCREASE_RATIO = 0

# Animation constants
export var ATTACK_ANIM_SPEED = 1.5
export var ATTACK_ANIM_DURATION = 1.0
var ATTACK_ANIM_NAME = 'player_idleattack01'
var ATTACK_ANIM_NAME_2 ='player_idleattack02' 

# Other
var SAFE_DISTANCE = 3
var SAFE_DISTANCE_SQUARED = SAFE_DISTANCE*SAFE_DISTANCE

# Scenes
onready var player_beam_scn = preload("res://scenes/player/player_beam.tscn")
onready var beam_particles_scn = preload("res://scenes/player/beam_particles.tscn")

# Shader
onready var invincible_shader = preload("res://shaders/player_invincible.tres")

# Nodes
onready var camera_pivot = $Pivot
onready var camera_animation_player = $Pivot/Camera/AnimationPlayer
onready var model = $Model
onready var animation_player = $Model/AnimationPlayer

# Variables
var velocity = Vector3.ZERO
var boost_direction = Vector3.ZERO
var blood = BASE_BLOOD_TOTAL
export var is_attacking = false
export var is_beam_ready = false
var has_moved = false
var is_boosting = false
var is_firing = false
var is_invincible = false
var is_stunned = false
var is_dead = false
var extra_life = 0
var camera_offset
var player_attack
var beam
var beam_particles

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

	camera_offset = camera_pivot.translation
	
	# Animation setup
	animation_player.playback_default_blend_time = 0.1
	animation_player.set_blend_time(ATTACK_ANIM_NAME, 'player_idle', 0.25)
	animation_player.set_blend_time(ATTACK_ANIM_NAME_2, 'player_idle', 0.25)
	
	# Connect global events
	connect("player_die", LevelManager, "on_player_die")

func _input(event):
	# Rotate camera and player when mouse moves
	if event is InputEventMouseMotion and !is_dead and !is_firing:
		var movement = event.relative

		# Rotate camera up and down
		camera_pivot.rotation.x += -deg2rad(movement.y * MOUSE_SENSITIVITY)
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg2rad(BASE_LOOK_ANGLE - MAX_VERTICLE_LOOK_ANGLE),
			deg2rad(BASE_LOOK_ANGLE + MAX_VERTICLE_LOOK_ANGLE))

		# Rotate character left and right
		rotation.y += -deg2rad(movement.x * MOUSE_SENSITIVITY)

func _physics_process(delta):
	# Disable movment/input if dead
	if is_dead:
		velocity = velocity.linear_interpolate(Vector3.ZERO, ACCELERATION)
		velocity = move_and_slide(velocity)
		return
	
	
	# Input #
	
	var input_direction = Vector3.ZERO
	var attack_velocity = Vector3.ZERO

	# Directional inputs
	# Use direction of camera to determine movement direction
	if Input.is_action_pressed('left'):
		input_direction -= camera_pivot.global_transform.basis.x
	if Input.is_action_pressed('right'):
		input_direction += camera_pivot.global_transform.basis.x
	if Input.is_action_pressed('forward'):
		input_direction -= camera_pivot.global_transform.basis.z
	if Input.is_action_pressed('back'):
		input_direction += camera_pivot.global_transform.basis.z
	if Input.is_action_pressed('down'):
		input_direction -= camera_pivot.global_transform.basis.y
	if Input.is_action_pressed('up'):
		input_direction += camera_pivot.global_transform.basis.y
	
	# Normalize input
	input_direction = input_direction.normalized()
	
	# Attack
	if Input.is_action_just_pressed('attack') and !Input.is_action_pressed('special') \
			and !is_attacking and !is_stunned and blood > 0:
		if animation_player.current_animation == ATTACK_ANIM_NAME:
			animation_player.play(ATTACK_ANIM_NAME_2)
		else:
			animation_player.play(ATTACK_ANIM_NAME, animation_player.playback_default_blend_time, \
				ATTACK_ANIM_SPEED)
		animation_player.queue("player_idle")
		deplete_blood(ATTACK_BLOOD_COST)
	# Boost
	if Input.is_action_pressed('boost') and !is_boosting and blood > 0 \
			and !is_stunned and !Input.is_action_pressed('special') and input_direction.length():
		boost_direction = input_direction
		is_boosting = true
		deplete_blood(BOOST_BLOOD_COST)
	# End boost
	if Input.is_action_just_released('boost'):
		is_boosting = false
	# Start aim
	if Input.is_action_just_pressed('special') and extra_life == 1:
		camera_animation_player.play('Aim')
		animation_player.play('player_shoot01', 0.1)
		emit_signal('activate_target')
		beam_particles = beam_particles_scn.instance()
		$Pivot/ShotPoint.add_child(beam_particles)
	# End aim
	if Input.is_action_just_released('special') and extra_life == 1:
		is_beam_ready = false
		camera_animation_player.play_backwards('Aim')
		animation_player.seek(animation_player.current_animation_position - 0.1)
		animation_player.play('player_shoot01', -1, -1)
		animation_player.queue('player_idle')
		if is_instance_valid(beam_particles):
			beam_particles.die()
		emit_signal('deactivate_target')
	# Shoot beam
	if Input.is_action_pressed('special') and Input.is_action_just_pressed('attack') \
		and extra_life == 1 and is_beam_ready and !is_stunned and !is_invincible:
		is_firing = true
		is_beam_ready = false
		blood = min(blood + SPECIAL_BLOOD_RECOVER, BASE_BLOOD_TOTAL)
		beam_particles.die()
		beam = player_beam_scn.instance()
		beam.connect('body_entered', self, '_on_hit')
		beam.connect('area_entered', self, '_on_hit')
		get_tree().current_scene.add_child(beam)
		beam.transform = $Pivot/ShotPoint.global_transform
		beam.shoot($Pivot/Camera)
		$Timer.start(BEAM_TIME)
		animation_player.play("player_shoot01")
		extra_life = 0
		emit_signal("update_life", extra_life)
		emit_signal('deactivate_target')
	# Draw aiming cross
	if Input.is_action_pressed('special'):
		var c = $Pivot/Camera
		var position = get_viewport().size / 2
		var from = c.project_ray_origin(position)
		var to = from + c.project_ray_normal(position) * 500
		var col = get_world().direct_space_state.intersect_ray(from, to, [], 1)
		if col:
			LineDrawer.add_line(col.position - camera_pivot.global_transform.basis.y, col.position + camera_pivot.global_transform.basis.y)
			LineDrawer.add_line(col.position - camera_pivot.global_transform.basis.x, col.position + camera_pivot.global_transform.basis.x)
			LineDrawer.add_line(col.position - camera_pivot.global_transform.basis.z, col.position + camera_pivot.global_transform.basis.z)
	
	# Deplete/regen blood
	if !is_boosting:
		blood_regen_modifier = min(blood_regen_modifier + (BLOOD_REGEN_ACCELERATION * delta), BLOOD_REGEN_MODIFIER_MAX)
	if $RegenTimer.is_stopped():
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
	var target_velocity = input_direction * VELOCITY \
		+ (boost_direction * BOOST_VELOCITY if is_boosting else Vector3.ZERO)
	
	if (input_direction.length() > 0 or boost_direction.length() > 0) and !is_stunned \
			and !is_firing:
		# Accelerate towards target velocity if there is input
		var acceleration = BOOST_ACCELERATION if is_boosting else ACCELERATION
		velocity = velocity.linear_interpolate(target_velocity, acceleration)
	elif is_stunned:
		velocity = velocity.linear_interpolate(Vector3.ZERO, STUNNED_DECELERATION)
	elif is_firing:
		velocity = velocity.linear_interpolate(camera_pivot.global_transform.basis.z \
			* BOOST_KNOCKBACK_ACCELERATION, BOOST_ACCELERATION)
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
	
	var rotated_velocity = velocity.rotated(Vector3.UP, -rotation.y).rotated(Vector3.RIGHT, -camera_pivot.rotation.x)
	
	# Swap between idle and dash animation
	if animation_player.current_animation == 'player_idle' and is_boosting and (rotated_velocity.z < 0 or abs(rotated_velocity.x) > VELOCITY):
		animation_player.play('player_dash', 0.25)
	if animation_player.current_animation == 'player_dash' and (!is_boosting or !(rotated_velocity.z < 0 or abs(rotated_velocity.x) <= VELOCITY)):
		animation_player.play('player_idle', 0.25)
	
	# Rotate model according to velocity
	model.rotation.z = -rotated_velocity.x \
			/ VELOCITY \
			* deg2rad(STRAFE_TILT_ANGLE)
	model.rotation.x = camera_pivot.rotation.x + rotated_velocity.z \
			/ VELOCITY \
			* deg2rad(STRAFE_TILT_ANGLE)
	model.rotation.y = -rotated_velocity.x / VELOCITY * deg2rad(STRAFE_Y_ROTATION)

	# Align player with camera after attacking
	if !is_instance_valid(player_attack) and camera_pivot.rotation.y != 0:
		var rotation_delta = (0 - camera_pivot.rotation.y) * delta * 5
		rotation.y -= rotation_delta
		camera_pivot.rotation.y += rotation_delta
		if abs(camera_pivot.rotation.y) < 0.001:
			camera_pivot.rotation.y = 0

	# Add camera lag
	var camera_lag = rotated_velocity * CAMERA_LAG * CAMERA_LAG_RATIOS
	camera_pivot.translation = camera_offset - camera_lag

	# Update blood bar
	emit_signal("update_blood", blood, BASE_BLOOD_TOTAL + blood_total_modifier)

	# Debug
	if Input.is_action_just_pressed("debug_button"):
		extra_life = 1
		emit_signal("update_life", extra_life)
	
	DebugOutput.add_output('velocity: ' + str(velocity.length()))
#	DebugOutput.add_output(animation_player.current_animation)
#	DebugOutput.add_output('is attacking: ' + str(is_attacking))
#	DebugOutput.add_output('is stunned: ' + str(is_stunned))
	DebugOutput.add_output('extra_life: ' + str(extra_life))
#	DebugOutput.add_output('invincible: ' + str(is_invincible))
#	DebugOutput.add_output('blood regen: ' + str(BASE_BLOOD_REGEN + blood_regen_modifier)) 
#	DebugOutput.add_output('animation: ' + str(animation_player.current_animation))
#	DebugOutput.add_output('is playing: ' + str(animation_player.is_playing()))
#	DebugOutput.add_output('position: ' + str(animation_player.current_animation_position))
#	DebugOutput.add_output('is attacking: ' + str(is_attacking))
#	DebugOutput.add_output('beam ready: ' + str(is_beam_ready))

func deplete_blood(amount):
	blood = max(blood - amount, 0)
	blood_regen_modifier = 0
	$RegenTimer.start(BLOOD_REGEN_COOLDOWN if blood > 0 else BLOOD_REGEN_ZERO_COOLDOWN)

func knock_back(speed, direction):
	velocity = direction * speed
	is_stunned = true
	is_boosting = false
	$Timer.start(STUN_TIME)

func _on_hit(col_entity):
	# Collide with enemy layer
	if col_entity.collision_layer & 4 or (col_entity.collision_layer & 64 and col_entity.get('is_destroyable')):
		col_entity.call_deferred('die', is_instance_valid(beam))
		# Don't add life for beam kills
		if !is_instance_valid(beam) and col_entity.get('EXTRA_LIFE'):
			extra_life = min(extra_life + col_entity.EXTRA_LIFE, 1)
			emit_signal("update_life", extra_life)
		return
	# Collide with cyst layer
	if col_entity.collision_layer & 8:
		var entity = col_entity.get_parent()
		_increase_blood(entity.blood_value)
		entity.queue_free()
		return

func die(damage = 1):
	if is_dead || is_invincible:
		return
	if extra_life == 1:
		extra_life = 0
		emit_signal("update_life", extra_life)
		is_invincible = true
		$Timer.start(INVINCIBLE_TIME)
		$Model/Armature/Skeleton/playermodel.material_override = invincible_shader
	else:
		is_dead = true
		$Model/Armature/Skeleton.physical_bones_start_simulation()
		emit_signal("player_die")

func _on_timeout():
	if is_firing:
		is_firing = false
		camera_animation_player.play_backwards('Aim')
	if is_invincible:
		is_invincible = false
		$Model/Armature/Skeleton/playermodel.material_override = null
	if is_stunned:
		is_stunned = false


# Currently unused #

func _increase_blood(blood_value):
	blood_total_modifier += blood_value * TOTAL_INCREASE_RATIO
	blood_regen_modifier += blood_value * REGEN_INCREASE_RATIO
	# boost_speed_modifier += blood_value * SPEED_INCREASE_RATIO

	blood = BASE_BLOOD_TOTAL + blood_total_modifier

	# Update blood bar total
	emit_signal("update_blood", blood, BASE_BLOOD_TOTAL + blood_total_modifier)
