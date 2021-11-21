extends MarginContainer

var output = []

func add_output(text):
	output.append(str(text))

func _physics_process(delta):
	$Output.text = ''
	
	for line in output:
		$Output.text += line + '\n'
	
	output.clear()
