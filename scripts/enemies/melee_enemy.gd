extends "res://scripts/enemies/enemy_base.gd"

# Constants
export var ATTACK_DISTANCE = 10
export var ACCELERATION = 0.05
export var DRAG = 0.025
export var KNOCK_BACK_SPEED = 35
export var PLAYER_KNOCK_BACK_SPEED = 20
export var ATTACK_ANGLE = 0.7
export var ATTACK_TIME = 0.3
export var COOLDOWN_TIME = 0.5
export var STUN_TIME = 1

# Scenes
onready var attack_scn = preload("res://scenes/enemies/stabby_attack.tscn")

var velocity = Vector3.ZERO
var is_attacking = false
var on_cooldown = false
var is_stunned = false
var attack

func attack_state(delta):
	var direction_to_player = translation.direction_to(player.translation)
	var player_dot = direction_to_player.dot(-transform.basis.z)
	if player_dot > ATTACK_ANGLE and !is_stunned:
		velocity = velocity.linear_interpolate(Vector3.FORWARD * SPEED * player_dot, ACCELERATION)
	else:
		velocity = velocity.linear_interpolate(Vector3.ZERO, DRAG)

	if !is_attacking:
		face_player(TURN_SPEED, delta)

	translate(velocity * delta)
	var distance_to_player = translation.distance_to(player.translation)
	if distance_to_player < ATTACK_DISTANCE and player_dot > ATTACK_ANGLE and !is_attacking and !on_cooldown:
		attack(player_dot)

func attack(player_dot):
		is_attacking = true
		attack = attack_scn.instance()
		attack.get_node('Hitbox').connect('body_entered', self, '_on_hit_player')
		attack.get_node('Hitbox').connect('area_entered', self, '_on_hit_attack')
		add_child(attack)
		$Timer.wait_time = ATTACK_TIME
		$Timer.start()

func die():
	if attack and attack.get_node('Hitbox').get_overlapping_areas():
		return
	.die()

func _on_hit_player(_body):
	Global.on_player_die()

func _on_hit_attack(_area):
	if KNOCK_BACK_SPEED:
		is_stunned = true
		velocity = Vector3.BACK * KNOCK_BACK_SPEED
	player.knock_back(PLAYER_KNOCK_BACK_SPEED)

func _on_timeout():
	._on_timeout()
	if is_attacking:
		if attack:
			attack.queue_free()
		is_attacking = false
		on_cooldown = true
		$Timer.wait_time = STUN_TIME if is_stunned else COOLDOWN_TIME
		$Timer.start()
		return
	if on_cooldown:
		on_cooldown = false
	if is_stunned:
		is_stunned = false

