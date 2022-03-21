extends Spatial

var mesh;
var mesh_size_factor;

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh_size_factor = 0;
	mesh = get_node("MeshInstance");

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
