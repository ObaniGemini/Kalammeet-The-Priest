extends StaticBody2D

export var pos1 = Vector2(0, 0)
export var pos2 = Vector2(0, 0)
onready var ray = get_node("RayCast2D")

var side = 0
const SPEED = 12

func _ready():
	set_pos(pos1)
	set_process_input(true)

func _input(event):
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.get_name() == "player":
			if event.is_action_pressed("crounch"):
				side = 1
			elif event.is_action_pressed("up"):
				side = -1
			set_fixed_process(true)

func _fixed_process(delta):
	if ray.is_colliding() and ray.get_collider().get_name() == "player":
		set_pos(get_pos()+Vector2(0, SPEED*side))
	else:
		var s = 1
		if abs(pos1.y - get_pos().y) < abs(pos2.y - get_pos().y):
			s = -1
		set_pos(get_pos()+Vector2(0, SPEED*s))
	
	if get_pos().y <= pos1.y:
		set_pos(pos1)
		set_fixed_process(false)
	elif get_pos().y >= pos2.y:
		set_pos(pos2)
		set_fixed_process(false)