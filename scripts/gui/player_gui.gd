extends Control

onready var fps_counter = $VBoxContainer/FPS/Counter
onready var blood_bar = $VBoxContainer/HBoxContainer/StatusContainer/RotationHolder/BloodBar
onready var health_container = $VBoxContainer/HBoxContainer/StatusContainer/HealthMargin/HealthContainer
onready var message_text = $VBoxContainer/HBoxContainer/MessageMargin/Message

onready var base_blood_size = blood_bar.rect_min_size.x
onready var base_message_size = message_text.get('custom_fonts/font').size
onready var filled_health_color = health_container.get_node("Health").color
onready var empty_health_color = health_container.get_node("Health2").color

func _process(delta):
	fps_counter.text = str(Engine.get_frames_per_second()) + " fps"

func update_blood(current, total):
	blood_bar.value = current
	blood_bar.rect_min_size.x += base_blood_size * ((total - blood_bar.max_value) / total)
	blood_bar.material.set_shader_param("bar_percentage", current)
	blood_bar.max_value = total

func update_health(current_health):
	for health_marker in health_container.get_children():
		if health_marker.get_index() < current_health - 1:
			health_marker.color = filled_health_color
		else:
			health_marker.color = empty_health_color

func display_message(text, font_size = 0, time = 4):
	message_text.text = text
	if font_size:
		message_text.get('custom_fonts/font').size = font_size
	$MessageTimer.start(time)

func clear_message():
	message_text.text = ""
	message_text.get('custom_fonts/font').size = base_message_size

