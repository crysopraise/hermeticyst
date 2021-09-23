extends Control

onready var blood_bar = $VContainer/HContainer/Blood/Bar
onready var message_text = $VContainer/Message/Text
onready var fps_counter = $VContainer/FPS/Counter
onready var debug_velocity = $VContainer/HContainer/Debug/Velocity

onready var base_blood_size = blood_bar.rect_min_size.x
onready var base_message_size = message_text.get('custom_fonts/font').size

func _process(delta):
	fps_counter.text = str(Engine.get_frames_per_second()) + " fps"

func reset_gui():
	update_max_blood(1)
	clear_message()
	
func update_blood(value):
	blood_bar.value = value

func update_max_blood(size):
	blood_bar.rect_min_size.x = base_blood_size * size

func update_velocity(velocity):
	debug_velocity.text = str(velocity.length())

func display_message(text, font_size = 0):
	message_text.text = text
	if font_size:
		message_text.get('custom_fonts/font').size = font_size

func clear_message():
	message_text.text = ""
	message_text.get('custom_fonts/font').size = base_message_size

