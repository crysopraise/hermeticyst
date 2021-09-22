extends Spatial

onready var bullet_spawner = $BulletSpawner
onready var player = get_tree().current_scene.get_node("Player")

func _physics_process(delta):
	if !bullet_spawner.is_shooting:
		var target_rotation = transform.looking_at(player.transform.origin, Vector3.UP)
		transform = transform.interpolate_with(target_rotation, delta)

