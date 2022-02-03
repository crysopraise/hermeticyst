extends ImmediateGeometry

var points = []

func _ready():
	var material = SpatialMaterial.new()
	material.vertex_color_use_as_albedo  = true
	set_material_override(material)

func add_line(start: Vector3, end: Vector3):
	points.append(start)
	points.append(end)

func _physics_process(delta):
	clear()

	begin(Mesh.PRIMITIVE_LINES)
	set_color(Color(1, 0, 0))

	for point in points:
		add_vertex(point)
	
	points.clear()
	
	end()

