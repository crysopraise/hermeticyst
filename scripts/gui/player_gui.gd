extends Control

onready var blood_bar = $VContainer/HContainer/Blood/Bar
onready var fps_counter = $VContainer/FPS/Counter
onready var debug_velocity = $VContainer/HContainer/Debug/Velocity
onready var base_blood_size = blood_bar.rect_size.x

func _process(delta):
	fps_counter.text = str(Engine.get_frames_per_second()) + " fps"
	
func update_blood(value):
	blood_bar.value = value

func update_max_blood(size):
	blood_bar.rect_size.x = base_blood_size * size

func update_velocity(velocity):
	debug_velocity.text = str(velocity.length())

