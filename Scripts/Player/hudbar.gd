extends TextureProgress

export var speed = 0.3
export var interpolation = 1
var active = false

func tween(value, restart=false):
	var start_value = get_value()
	if restart:
		start_value = 0
	active = true
	get_node("Tween").stop_all()
	get_node("Tween").interpolate_property(self, "range/value", start_value, value, speed, interpolation, 1)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	active = false