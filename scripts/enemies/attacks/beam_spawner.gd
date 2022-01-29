extends Spatial

signal attack_finished

export var BEAM_LENGTH = 200

var beam
export var beam_active = false
export var target_slow = 1.0
var frame_update

func _ready():
	_resize_beam(BEAM_LENGTH)
	frame_update = randi() % 2

func _physics_process(delta):
	if $AnimationPlayer.current_animation != 'RESET' and Engine.get_physics_frames() % 2 == frame_update:
		var collision = get_world().direct_space_state.intersect_ray(
			global_transform.origin,
			global_transform.origin + (-global_transform.basis.z * BEAM_LENGTH),
			[],
			1
		)
		if collision:
			_resize_beam(global_transform.origin.distance_to(collision.position))
		else:
			_resize_beam(BEAM_LENGTH)

func shoot():
	$AnimationPlayer.play("Target")
	print($AnimationPlayer.is_playing())

func stop_attack():
	$AnimationPlayer.play("RESET")

func _resize_beam(length):
	$Tracer.mesh.height = length
	$Tracer.transform.origin.z = -length / 2
	$Beam/MeshInstance.mesh.height = length
	$Beam/CollisionShape.shape.height = length
	$Beam.transform.origin.z = -length / 2

func _on_animation_finished(anim_name):
	if anim_name == 'Target':
		$AnimationPlayer.play("Beam")
	if anim_name == 'Beam':
		$AnimationPlayer.play("RESET")
		emit_signal('attack_finished')

func _on_hit_player(body):
	body.die(2)
