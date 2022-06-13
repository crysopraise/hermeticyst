extends ImmediateGeometry

var points = []

func _ready():
	var material = SpatialMaterial.new()
	material.vertex_color_use_as_albedo  = true
	set_material_override(material)

func add_line(start: Vector3, end: Vector3, color: Color = Color(1, 0, 0)):
	points.append(color)
	points.append(start)
	points.append(end)

func _physics_process(delta):
	clear()

	begin(Mesh.PRIMITIVE_LINES)
	
	var i = 0
	while i < points.size():
		set_color(points[i])
		add_vertex(points[i+1])
		add_vertex(points[i+2])
		i += 3
	
	points.clear()
	
	end()

