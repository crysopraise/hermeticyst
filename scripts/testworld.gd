extends Spatial

var guy_count = 1

func _ready():
	randomize()

func _process(delta):
	$FPS.text = str(Engine.get_frames_per_second()) + " fps"

	#if Input.is_action_just_pressed("debug_button"):
	#	var guy = preload("res://scenes/enemies/enemy.tscn").instance()
	#	guy.translation = $Player.translation
	#	guy.translation.z -= 3
	#	add_child(guy)
	#	guy_count += 1
	#	$GuyCount.text = "Guys: " + str(guy_count)

