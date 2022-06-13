extends "res://scripts/enemies/melee_enemy.gd"

export var MAX_RANGE = 100
export var MELEE_RANGE = 50
export var RANGED_COOLDOWN_TIME = 2
export var BULLET_SPEED = 50
export var STRAFE_SPEED = 30
export var RANGED_ATTACK_ANIM_SPEED = 1.5

func _ready():
	._ready()
	BulletManager.create_pool(name, 'bullet')
	animation_player.animation_set_next(ANIM_PREFIX + '_ranged', ANIM_PREFIX + '_idle')

func active_state(delta):
	var distance_to_player = translation.distance_to(player.translation)
	var target_velocity
	if distance_to_player > MAX_RANGE:
		target_velocity = -transform.basis.z * SPEED
		target_velocity = navigate_to_target(delta, target_velocity, TURN_SPEED)
	elif distance_to_player > MELEE_RANGE:
		target_velocity = transform.basis.x * strafe_dir * STRAFE_SPEED
		target_velocity = navigate_while_strafing(delta, target_velocity, TURN_SPEED)
	else:
		target_velocity = -transform.basis.z * SPEED
		if on_cooldown:
			target_velocity = target_velocity * REVERSE_SPEED_MOD
		target_velocity = navigate_to_target(delta, target_velocity, TURN_SPEED)
	velocity = velocity.linear_interpolate(target_velocity, ACCELERATION)
	velocity = move_and_slide(velocity)
	
	player_dot = get_player_dot()
	if player_dot > ATTACK_ANGLE and !is_attacking and !on_cooldown:
		if distance_to_player < ATTACK_DISTANCE:
			attack()
		elif distance_to_player > MELEE_RANGE:
			ranged_attack()

func ranged_attack():
	animation_player.play(ANIM_PREFIX + '_ranged', 0.1, RANGED_ATTACK_ANIM_SPEED)
	on_cooldown = true
	$Timer.start(RANGED_COOLDOWN_TIME)

func fire_bullet():
	BulletManager.fire_bullet(name, {
		'position': translation,
		'direction': translation.direction_to(player.translation),
		'speed': BULLET_SPEED,
	})
