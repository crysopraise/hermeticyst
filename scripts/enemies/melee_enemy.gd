extends "res://scripts/enemies/enemy.gd"

# Constants
export var ATTACK_DISTANCE = 10
export var PLAYER_KNOCK_BACK_SPEED = 20
export var KNOCK_BACK_SPEED = 45
export var ATTACK_ANGLE = 0.7
export var STUN_TIME = 1.2
export var DRAG = 0.025
export var TURN_MOD = 0.4
export var INVINCIBLE_FRAMES = 0.1

# Animation
export var STUN_ANIM_SPEED = 1.0
export var STUN_ANIM_BLEND = 0.3

# Scenes
#onready var attack_scn = preload("res://scenes/enemies/attacks/stabby_attack.tscn")
var attack_scn

# Variables
export var attack_boost = 1.0
var is_stunned = false
var is_invincible = false
var player_dot = 0
var enemy_attack

func _enter_tree():
	attack_scn = load("res://scenes/enemies/attacks/" + name.to_lower().rstrip('0123456789') + "_attack.tscn")

func _ready():
	._ready()
	if animation_player:
		animation_player.set_blend_time(ANIM_PREFIX + '_stun', ANIM_PREFIX + '_idle', STUN_ANIM_BLEND)
		animation_player.animation_set_next(ANIM_PREFIX + '_attack', ANIM_PREFIX + '_idle')

func active_state(delta):
	if animation_player and !is_stunned:
		animation_player.play(ANIM_PREFIX + '_idle', 0.2)
	player_dot = get_player_dot()
	var target_velocity = -transform.basis.z * SPEED

#	if !on_cooldown:
	var turn_mod = 1.0 + (max(0, player_dot) * TURN_MOD)
	target_velocity = navigate_to_target(delta, target_velocity, TURN_SPEED * turn_mod)
	if on_cooldown:
		target_velocity = -target_velocity

#	if !is_stunned and !on_cooldown:
	if !is_stunned:
		velocity = velocity.linear_interpolate(target_velocity, ACCELERATION)
	else:
		velocity = velocity.linear_interpolate(Vector3.ZERO, DRAG)

	velocity = move_and_slide(velocity)
	var distance_to_player = translation.distance_to(player.translation)
	if distance_to_player < ATTACK_DISTANCE and player_dot > ATTACK_ANGLE and !is_attacking and !on_cooldown:
		attack()

func attack_state(delta):
	face_target(TURN_SPEED, delta)
	velocity = move_and_slide(velocity.linear_interpolate(-transform.basis.z * SPEED * attack_boost, ACCELERATION))

func attack():
	if animation_player:
		if animation_player.current_animation == ANIM_PREFIX + '_attack':
			animation_player.seek(0, true)
		animation_player.play(ANIM_PREFIX + '_attack', 0.1, ATTACK_ANIM_SPEED)
	is_attacking = true
	$Timer.start(ATTACK_TIME / ATTACK_ANIM_SPEED)

func is_colliding_with_attack():
#	return is_attacking and $AttackHitbox.get_overlapping_areas()
	return !$AttackHitbox/CollisionShape.disabled and $AttackHitbox.get_overlapping_areas()

func die(is_beam = false):
	if !is_beam and is_colliding_with_attack():
		return true # Return true if death failed
	.die()

func _on_hit_player(body):
	body.die()

func _on_hit_attack(area):
	var is_hazard_knockback = area.is_in_group('hazard')
	if is_hazard_knockback and !area.HAS_KNOCKBACK:
		return

	if KNOCK_BACK_SPEED:
		var knock_back_point = area.translation if is_hazard_knockback else player.translation
		velocity = knock_back_point.direction_to(translation) * KNOCK_BACK_SPEED + player.velocity

		if animation_player:
			animation_player.play(ANIM_PREFIX + '_stun', 0.1, STUN_ANIM_SPEED)
		is_attacking = false
		is_stunned = true
		$Timer.start(STUN_TIME)

	if !is_hazard_knockback:
		player.knock_back(PLAYER_KNOCK_BACK_SPEED, translation.direction_to(player.translation))

func _on_timeout():
	._on_timeout()
	print('timeout')
	if is_attacking:
		is_attacking = false
		on_cooldown = true
		$Timer.start(COOLDOWN_TIME)
		return
	if on_cooldown:
		on_cooldown = false
	if is_stunned:
		is_stunned = false
