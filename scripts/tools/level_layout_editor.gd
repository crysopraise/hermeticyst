extends Control

# Constants
var CONNECTION_COLOR = Color("a83427") 
var CONNECTION_WIDTH = 10
var ZOOM_INCREMENT = 0.1
var LAYOUT_FILE_PATH = 'res://data/level_layout.save'

# Scenes
var level_node_scn = preload("res://scenes/tools/level_node.tscn")

onready var new_level_button = $Menu/MenuiContainer/NewLevel

var making_connection = false
var active_node
var hover_node

func _ready():
	# Load data to dict
	var file = File.new()
	if file.file_exists(LAYOUT_FILE_PATH):
		file.open(LAYOUT_FILE_PATH, File.READ)
		var data_dict = file.get_var(true)
		file.close()

		# Load data to scene
		if "screen_position" in data_dict:
			$Levels.rect_position = data_dict['screen_position']
		if "levels" in data_dict:
			for node in data_dict['levels']:
				var level_node = level_node_scn.instance().init(node["unique_id"])
				level_node.rect_position = node.position
				level_node.connections = node.connections
				$Levels.add_child(level_node)

			var level_nodes = $Levels.get_children()
			for level_node in level_nodes:
				for i in range(level_node.connections.size()):
					for possible_connection in level_nodes:
						if possible_connection.unique_id == level_node.connections[i]:
							level_node.connections[i] = possible_connection
							break

func _on_gui_input(event):
	if event is InputEventMouseMotion:
		update()
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and hover_node:
			hover_node.rect_position += event.relative
		elif Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.is_mouse_button_pressed(BUTTON_MIDDLE):
			$Levels.rect_position += event.relative
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			making_connection = false

		# Unfinished zoom
# 		if event.button_index == BUTTON_WHEEL_UP:
# 			$Levels.rect_scale.x += min(1, ZOOM_INCREMENT)
# 			$Levels.rect_scale.y += min(1, ZOOM_INCREMENT)
# 		if event.button_index == BUTTON_WHEEL_DOWN:
# 			$Levels.rect_scale.x -= max(0, ZOOM_INCREMENT)
# 			$Levels.rect_scale.y -= max(0, ZOOM_INCREMENT)

func _draw():
	var screen_offset = $Levels.rect_position

	if making_connection:
		draw_line(
			active_node.rect_position + screen_offset,
			get_viewport().get_mouse_position(),
			CONNECTION_COLOR, CONNECTION_WIDTH)
	
	var drawn_connections = []
	for node in $Levels.get_children():
		for connected_node in node.connections:
			if !drawn_connections.has([connected_node, node]):
				draw_line(
					node.rect_position + screen_offset,
					connected_node.rect_position + screen_offset,
					CONNECTION_COLOR, CONNECTION_WIDTH)
				drawn_connections.append([node, connected_node])	


func _on_new_level():
	if active_node:
		active_node.deselect()
	active_node = level_node_scn.instance().init(null, false)
	active_node.rect_position = get_viewport().size / 2 - $Levels.rect_position
	$Levels.add_child(active_node)
	active_node.select()

func _on_delete_level():
	if active_node:
		for connected_node in active_node.connections:
			connected_node.connections.erase(active_node)
		active_node.queue_free()

func select_node(node, rmb_pressed):
	print(active_node)
	if active_node:
		if node.get_instance_id() == active_node.get_instance_id():
			print('active node already selected')
			making_connection = rmb_pressed
			return
	
	if making_connection:
		print('making connection from active node: ', active_node.get_instance_id(), ' to node: ', node.get_instance_id())
		if active_node.connections.has(node):
			return
		active_node.connections.append(node)
		node.connections.append(active_node)
		making_connection = false
	else:
		print('node selected: ', node.get_instance_id(), ', making connection: ', rmb_pressed)
		if active_node:
			active_node.deselect()
		node.select()
		active_node = node
		making_connection = rmb_pressed

func _on_save():
	# Compile data to dictionary
	var data_dict = {"levels": [], "screen_position": $Levels.rect_position}
	for node in $Levels.get_children():
		var connection_ids = []
		for connection in node.connections:
			connection_ids.append(connection.unique_id)
		data_dict["levels"].append({
			"unique_id": node.unique_id,
			"position": node.rect_position,
			"connections": connection_ids
		})
	
	# Save data to file
	var file = File.new()
	file.open(LAYOUT_FILE_PATH, File.WRITE)
	file.store_var(data_dict, true)
	file.close()

func _on_clear():
	for c in $Levels.get_children():
		c.queue_free()

func set_hover_node(node):
	hover_node = node

func remove_hover_node(node_id):
	if hover_node and node_id == hover_node.get_instance_id():
		hover_node = null

