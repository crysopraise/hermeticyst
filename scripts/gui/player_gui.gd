extends Control

onready var fps_counter = $FPSCounter
onready var blood_bar = $HBoxContainer/BloodBarContainer/Position/ProgressRotation/BloodBar
onready var blood_bar_anim = $HBoxContainer/BloodBarContainer/Position/BloodBarAnim
onready var extra_life = $HBoxContainer/BloodBarContainer/Position/ExtraLife
onready var message_text = $HBoxContainer/MessageMargin/Message
onready var target = $TargetContainer/TargetCenter/Target

onready var base_blood_size = blood_bar.rect_min_size.x
onready var base_message_size = message_text.get('custom_fonts/font').size
onready var filled_life_color = Color(0.6, 0.1, 0.1)
onready var empty_life_color = extra_life.color

func connect_signals(player):
	player.connect("update_blood", self, "update_blood")
	player.connect("update_life", self, "update_life")
	player.connect("activate_target", target, "activate")
	player.connect("deactivate_target", target, "deactivate")

func _process(delta):
	fps_counter.text = str(Engine.get_frames_per_second()) + " fps"

func update_blood(current, total):
	blood_bar.value = current
	blood_bar.rect_min_size.x += base_blood_size * ((total - blood_bar.max_value) / total)
	blood_bar.material.set_shader_param("bar_percentage", current)
	blood_bar.max_value = total

func update_life(value):
	if value == 1:
		extra_life.color = filled_life_color
	else:
		extra_life.color = empty_life_color

func display_message(text, font_size = 0, time = 4):
	message_text.text = text
	if font_size:
		message_text.get('custom_fonts/font').size = font_size
	$MessageTimer.start(time)

func clear_message():
	message_text.text = ""
	message_text.get('custom_fonts/font').size = base_message_size


func _on_VideoPlayer_finished():
	blood_bar_anim.play()
