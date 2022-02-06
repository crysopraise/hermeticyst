extends "res://scripts/enemies/enemy.gd"

# Constants
var MAX_ANGLE = deg2rad(30)


# Nodes
#var polyp_bullet

# Variables
var player_out_of_range = true
var range_check = randi() % 2

func _ready():
#	polyp_bullet = preload('res://scenes/enemies/attacks/polyp_bullet.tscn').instance().init()
#	var level = get_tree().current_scene
#	BulletManager.add_child(polyp_bullet)
#	connect('tree_exited', self, 'on_exit')
	BulletManager.create_pool('polyp_bullet')

#func on_exit():
#	polyp_bullet.queue_free()

func attack_state(delta):
	if range_check == Engine.get_physics_frames() % 2:
		player_out_of_range = is_player_out_of_range()
	
	if !player_out_of_range:
		BulletManager.fire_bullet('polyp_bullet', {
			'position': $SpawnPoint.global_transform.origin,
			'direction': global_transform.basis.y
		})
		is_attacking = false
		$Timer.start(COOLDOWN_TIME)

func _on_timeout():
	._on_timeout()
	is_attacking = true

func is_player_out_of_range():
	return transform.origin.distance_squared_to(player.transform.origin) \
			> ARGRO_RANGE_SQUARED \
			or get_world().direct_space_state.intersect_ray(
				transform.origin,
				player.transform.origin,
				[],
				1
			)

