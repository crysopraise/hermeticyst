extends Control

# Signals
signal node_selected(node, rmb_pressed)
signal node_hover(node)
signal node_exit(node_id)
signal node_removed()

# Helper
var uuid_util = preload("res://asset_lib/uuid.gd")

# Variables
var connections = []
var select_in_ready = false
var unique_id
var base_color
var selected_color

func init(existing_id, selected:bool = false):
	if existing_id:
		print(typeof(existing_id))
		unique_id = existing_id
	else:
		unique_id = uuid_util.v4()

	select_in_ready = selected

	return self

func _ready():
	var layout_editor = get_tree().current_scene
	if layout_editor.name == 'LevelLayoutEditor':
		connect('node_selected', layout_editor, 'select_node')
		connect('node_hover', layout_editor, 'set_hover_node')
		connect('node_exit', layout_editor, 'remove_hover_node')
		connect('node_removed', layout_editor, 'update')
	
	# Store base and selected color and reset border color
	var style_box = $Panel.get('custom_styles/panel')
	base_color = style_box.bg_color
	selected_color = style_box.border_color
	if !select_in_ready:
		style_box.border_color = base_color

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT:
			emit_signal('node_selected', self, event.button_index == BUTTON_RIGHT)
			accept_event()

func _on_mouse_entered():
	emit_signal('node_hover', self)

func _on_mouse_exited():
	emit_signal('node_exit', get_instance_id())

func _on_tree_exited():
	emit_signal('node_removed')

func select():
	$Panel.get('custom_styles/panel').border_color = selected_color

func deselect():
	print('deselecting node: ', get_instance_id())
	$Panel.get('custom_styles/panel').border_color = base_color

