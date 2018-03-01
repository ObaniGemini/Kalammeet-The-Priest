extends Node

func new_timer(time):
	var timer = Timer.new()
	timer.set_wait_time(time)
	timer.set_one_shot(true)
	return timer