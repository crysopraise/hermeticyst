extends Spatial

var MOUSE_SENSITIVITY = 0.5
var rotate_camera = false
var rotate_vector = false
var forward = Vector3(0, 0, -1)
var right
var up

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			rotate_camera = event.pressed
		if event.button_index == BUTTON_RIGHT:
			rotate_vector = event.pressed
	if event is InputEventMouseMotion and rotate_camera:
		var movement = event.relative
		# Rotate camera up and down
		$Pivot.rotation.x += -deg2rad(movement.y * MOUSE_SENSITIVITY)
		# Rotate character left and right
		$Pivot.rotation.y += -deg2rad(movement.x * MOUSE_SENSITIVITY)
	if event is InputEventMouseMotion and !rotate_camera and rotate_vector:
		var movement = event.relative
		# Rotate camera up and down
		forward = forward.rotated(Vector3.RIGHT, -deg2rad(movement.y * MOUSE_SENSITIVITY))
		# Rotate character left and right
		forward = forward.rotated(Vector3.UP, -deg2rad(movement.x * MOUSE_SENSITIVITY)).normalized()

func _process(delta):
	# Cardinal directions
	LineDrawer.add_line(Vector3.ZERO, Vector3.UP * 0.5, Color(0.75, 0.75, 0.75))
	LineDrawer.add_line(Vector3.ZERO, Vector3.RIGHT * 0.5, Color(0.75, 0.75, 0.75))
	LineDrawer.add_line(Vector3.ZERO, Vector3.BACK * 0.5, Color(0.75, 0.75, 0.75))
	
	var up = forward.rotated
#	var up = forward.cross(Vector3.LEFT)
	var right = forward.cross(Vector3.UP)
	
	LineDrawer.add_line(Vector3.ZERO, forward, Color(0, 0, 1))
	LineDrawer.add_line(Vector3.ZERO, right, Color(1, 0, 0))
	LineDrawer.add_line(Vector3.ZERO, up, Color(0, 1, 0))
	
	DebugOutput.add_output(['forward: ', forward])
	DebugOutput.add_output(['right: ', right])
	DebugOutput.add_output(['up: ', up])
