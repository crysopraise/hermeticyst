extends Control

onready var fps_counter = $VBoxContainer/FPS/Counter
onready var blood_bar_anim = $VBoxContainer/HBoxContainer/StatusContainer/BloodBarContainer/BloodBarAnim
onready var blood_bar = $VBoxContainer/HBoxContainer/StatusContainer/BloodBarContainer/RotationHolder/BloodBar
onready var health_ui = $VBoxContainer/HBoxContainer/StatusContainer/HealthMargin/HealthUI
onready var message_text = $VBoxContainer/HBoxContainer/MessageMargin/Message
onready var target = $TargetContainer/TargetCenter/Target

onready var base_blood_size = blood_bar.rect_min_size.x
onready var base_message_size = message_text.get('custom_fonts/font').size
onready var filled_health_color = Color(0.6, 0.1, 0.1)
onready var empty_health_color = health_ui.color

func connect_signals(player):
	player.connect("update_blood", self, "update_blood")
	player.connect("update_life", self, "update_life")
	player.connect("activate_target", target, "activate")
	player.connect("deactivate_target", target, "deactivate")

func _process(delta):
	fps_counter.text = str(Engine.get_frames_per_second()) + " fps"
	DebugOutput.add_output('activating: ' + str(target.activating))
	DebugOutput.add_output('anim: ' + str(target.animation))

func update_blood(current, total):
	blood_bar.value = current
	blood_bar.rect_min_size.x += base_blood_size * ((total - blood_bar.max_value) / total)
	blood_bar.material.set_shader_param("bar_percentage", current)
	blood_bar.max_value = total

func update_life(extra_life):
	if extra_life == 1:
		health_ui.color = filled_health_color
	else:
		health_ui.color = empty_health_color
#	for health_marker in health_container.get_children():
#		if health_marker.get_index() < current_health - 1:
#			health_marker.color = filled_health_color
#		else:
#			health_marker.color = empty_health_color

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
