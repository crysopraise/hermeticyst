extends AnimatedSprite

var activating = false

func _ready():
	connect('animation_finished', self, '_on_animation_finished')

func activate():
	activating = true
	if !visible:
		visible = true
	play('Startup')

func deactivate():
	activating = false
	play('Startup', true)

func _on_animation_finished():
	if animation == 'Startup':
		if activating:
			play('Loop')
		else:
			visible = false
			stop()
