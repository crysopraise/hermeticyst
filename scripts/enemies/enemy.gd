extends KinematicBody

export var MAX_VELOCITY = 100
export var ACCELERATION = 0.05
export var DRAG = 0.025
export var STRAFE_TILT_ANGLE = 10

onready var mesh = $Mesh

var velocity = Vector3.ZERO
var stun_timer = Timer.new()
var hit_material

func _ready():
	hit_material = SpatialMaterial.new()
	hit_material.albedo_color = Color(0.8, 0.9, 0.2, 1.0)
	stun_timer.connect("timeout", self, "_on_stun_end")
	stun_timer.one_shot = true
	add_child(stun_timer)

func _physics_process(delta):
	var direction_velocity = Vector3.ZERO

	if direction_velocity.length() > 0:
		velocity = velocity.linear_interpolate(direction_velocity, ACCELERATION)
	else:
		velocity = velocity.linear_interpolate(Vector3.ZERO, DRAG)
	
	var rotated_velocity = velocity.rotated(Vector3.UP, -rotation.y)

	mesh.rotation.z = -rotated_velocity.x \
			/ MAX_VELOCITY \
			* deg2rad(STRAFE_TILT_ANGLE)

	velocity = move_and_slide(velocity)

func damage(momentum):
	velocity += momentum
	mesh.material_override = hit_material
	stun_timer.start()

func _on_stun_end():
	print("enemy stun end")
	mesh.material_override = null

