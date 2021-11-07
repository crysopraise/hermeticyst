extends 'res://scripts/environment/hazard.gd'

func _on_destroyable_hit(_area):
	$Destroyable.queue_free()

