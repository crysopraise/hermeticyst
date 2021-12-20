extends Control

onready var blood_bar = $VContainer/HContainer/Blood/TextureBar
onready var message_text = $VContainer/Message/Text
onready var fps_counter = $VContainer/FPS/Counter
onready var debug_velocity = $VContainer/HContainer/Debug/Velocity

onready var base_blood_size = blood_bar.rect_min_size.x
onready var base_message_size = message_text.get('custom_fonts/font').size
onready var base_beat_frequency = blood_bar.material.get_shader_param('beat_frequency')
onready var base_flow_rate = blood_bar.material.get_shader_param('flow_rate')

func _process(delta):
	fps_counter.text = str(Engine.get_frames_per_second()) + " fps"

func update_blood(current, total):
	blood_bar.value = current
	blood_bar.rect_min_size.x += base_blood_size * ((total - blood_bar.max_value) / total)
	blood_bar.material.set_shader_param("bar_percentage", current)
	blood_bar.max_value = total

func set_blood_bar_speed(multiplier):
	blood_bar.material.set_shader_param('beat_frequency', base_beat_frequency * multiplier)
	blood_bar.material.set_shader_param('flow_rate', base_flow_rate * multiplier)
	

func display_message(text, font_size = 0, time = 4):
	message_text.text = text
	if font_size:
		message_text.get('custom_fonts/font').size = font_size
	$MessageTimer.start(time)

func clear_message():
	message_text.text = ""
	message_text.get('custom_fonts/font').size = base_message_size

