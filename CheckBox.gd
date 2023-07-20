extends CheckBox


var callback: Callable
var callback_arg



func set_callback(lambda, arg):
	self.callback = lambda
	self.callback_arg = arg

func _pressed():
	if callback:
		if callback_arg:
			callback.call(callback_arg)
		else:
			callback.call()
		print("called callback")
	else:
		print("CALLBACK IS NOT SET")
