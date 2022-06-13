extends MarginContainer

var output = []

func add_output(text):
	if typeof(text) == TYPE_ARRAY:
		var string = ''
		for t in text:
			string += str(t)
		output.append(string)
	else:
		output.append(str(text))

func _physics_process(delta):
	$Output.text = ''
	
	for line in output:
		$Output.text += line + '\n'
	
	output.clear()
