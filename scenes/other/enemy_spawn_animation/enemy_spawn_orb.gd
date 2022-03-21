extends Spatial

var mesh;
var mesh_size_factor;
var timer;

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = 0;
	mesh = get_node("MeshInstance");
	mesh_size_factor = 0.001;
	mesh.scale = Vector3(mesh_size_factor, mesh_size_factor, mesh_size_factor);
	
func _process(delta):
	timer += delta;
	if mesh_size_factor < 1.0:
		mesh_size_factor += delta * 1.0;
		if mesh_size_factor > 1.0:
			mesh_size_factor = 1.0;
		print(mesh_size_factor);
		mesh.scale = Vector3(mesh_size_factor, mesh_size_factor, mesh_size_factor);
	else:
		var dissolve_amount = timer - 2.0;
		if dissolve_amount >= 0.0:
			var material = mesh.get_surface_material(0);
			material.set_shader_param("dissolve_amount", dissolve_amount);
			mesh.set_surface_material(0, material);
	
