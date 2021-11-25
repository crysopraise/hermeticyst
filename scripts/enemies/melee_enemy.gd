extends "res://scripts/enemies/enemy_base.gd"

# Constants
export var ATTACK_DISTANCE = 10
export var PLAYER_KNOCK_BACK_SPEED = 20
export var KNOCK_BACK_SPEED = 45
export var ATTACK_ANGLE = 0.7
export var STUN_TIME = 1
export var DRAG = 0.025
export var TURN_MOD = 0.4

# Scenes
onready var attack_scn = preload("res://scenes/enemies/attacks/stabby_attack.tscn")

# Nodes
onready var animation_player = $Model/AnimationPlayer

# Variables
var is_stunned = false
var enemy_attack

func active_state(delta):
	if animation_player:
		animation_player.play(ANIM_PREFIX + '_idle')
	var direction_to_player = translation.direction_to(player.translation)
	var player_dot = direction_to_player.dot(-transform.basis.z)
	var target_velocity = -transform.basis.z * SPEED

	if !on_cooldown:
		var turn_mod = 1.0 + (max(0, player_dot) * TURN_MOD)
		target_velocity = navigate_to_target(delta, target_velocity, TURN_SPEED * turn_mod)

	if !is_stunned and !on_cooldown:
		velocity = velocity.linear_interpolate(target_velocity, ACCELERATION)
	else:
		velocity = velocity.linear_interpolate(Vector3.ZERO, DRAG)

	velocity = move_and_slide(velocity)
	var distance_to_player = translation.distance_to(player.translation)
	if distance_to_player < ATTACK_DISTANCE and player_dot > ATTACK_ANGLE and !is_attacking and !on_cooldown:
		attack()

func attack_state(_delta):
	velocity = move_and_slide(velocity.linear_interpolate(Vector3.ZERO, DRAG))

func attack():
	if animation_player:
		animation_player.play(ANIM_PREFIX + '_attack', 0.1)
	is_attacking = true
#		enemy_attack = attack_scn.instance()
#		enemy_attack.get_node('Hitbox').connect('body_entered', self, '_on_hit_player')
#		enemy_attack.get_node('Hitbox').connect('area_entered', self, '_on_hit_attack')
#		add_child(enemy_attack)
	$Timer.start(ATTACK_TIME)

func is_colliding_with_attack():
	return is_instance_valid(enemy_attack) and enemy_attack.get_node('Hitbox').get_overlapping_areas()

func die():
	if is_colliding_with_attack():
		return
	.die()

func _on_hit_player(body):
	body.die()

func _on_hit_attack(_area):
	if KNOCK_BACK_SPEED:
		is_stunned = true
		velocity = player.translation.direction_to(translation) * KNOCK_BACK_SPEED + player.velocity
		animation_player.play(ANIM_PREFIX + '_stun', 0.1)
	player.knock_back(PLAYER_KNOCK_BACK_SPEED, translation.direction_to(player.translation))

func _on_timeout():
	._on_timeout()
	if is_attacking:
		if is_instance_valid(enemy_attack):
			enemy_attack.queue_free()
		is_attacking = false
		on_cooldown = true
		$Timer.start(STUN_TIME if is_stunned else COOLDOWN_TIME)
		return
	if on_cooldown:
		on_cooldown = false
	if is_stunned:
		is_stunned = false

