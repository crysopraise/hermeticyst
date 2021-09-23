extends Control

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		get_tree().reload_current_scene()

