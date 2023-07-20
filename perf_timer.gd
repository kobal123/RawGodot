extends Node

func mss():
	return Time.get_ticks_msec()

func mse(time, string):
	print(string, "TOOK: ", Time.get_ticks_msec() - time)

