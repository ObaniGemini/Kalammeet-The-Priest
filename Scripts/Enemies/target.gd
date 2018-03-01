extends KinematicBody2D

const protecting = false #virtual
const dodging = false #virtual
const steps = 0.45
const damping = 1.10

var power = 0
var step = 1

func damage(value, side):
	power += 0.01*value
	get_node("Tween").stop_all()
	get_node("Tween").interpolate_property(get_node("Node2D/Sprite"), "modulate", Color(1, 1-(power*3), 1-(power*3)), Color(1, 1, 1), 1, 0, 1)
	get_node("Tween").start()
	if not is_fixed_processing():
		set_fixed_process(true)

func _fixed_process(delta):
	if power < 0.005:
		power = 0
		step = 0
		set_fixed_process(false)
		return
	step += steps
	power /= damping
	get_node("Node2D").set_rot(sin(step)*power)