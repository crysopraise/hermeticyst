extends Skeleton

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_F:
			physical_bones_start_simulation(['neck', 'bicep.R', 'bicep.L'])
		if event.pressed and event.scancode == KEY_G:
			physical_bones_start_simulation()
