extends CheckBox


var callback: Callable
var callback_arg



func set_callback(lambda, arg = null):
	self.callback = lambda
	self.callback_arg = arg
	


func _pressed():
	if callback:
		if callback_arg != null:
			if callback_arg is Array:
				callback.callv(callback_arg)
				print("called with arguments array")
			else:
				callback.call(callback_arg)
				print("called with arguments")
		else:
			callback.call()
			print("called without arguments")
#		print("called callback")

	else:
		print("CALLBACK IS NOT SET")
