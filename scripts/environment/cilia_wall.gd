extends "res://scripts/environment/hazard.gd"

func _ready():
	var collision_shapes = get_children()
	var mat = SpatialMaterial.new()
	mat.albedo_color = Color.red
	for shape in collision_shapes:
		var arr_mesh = ArrayMesh.new()
		var arrays = []
		arrays.resize(ArrayMesh.ARRAY_MAX)
		var vertices = PoolVector3Array()
		for point in shape.polygon:
			vertices.push_back(Vector3(point.x, point.y, shape.depth / 2))
		arrays[ArrayMesh.ARRAY_VERTEX] = vertices
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_FAN, arrays)
		arr_mesh.surface_set_material(0, mat)
		var mesh_instance = MeshInstance.new()
		mesh_instance.mesh = arr_mesh
		mesh_instance.transform = shape.transform
		add_child(mesh_instance)
