extends ImmediateGeometry

var points = []

func add_line(start: Vector3, end: Vector3):
	points.append(start)
	points.append(end)

func _physics_process(delta):
	clear()

	begin(Mesh.PRIMITIVE_LINES)

	for point in points:
		add_vertex(point)
	
	points.clear()
	
	end()

