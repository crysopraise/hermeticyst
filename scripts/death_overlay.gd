extends Control

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		LevelManager.reset_level()

