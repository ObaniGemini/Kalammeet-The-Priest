extends Area2D

const health = 10
var speed = 60
var angle = 0
var sprite = randi()%4

func _ready():
	get_node("AnimatedSprite").set_frame(sprite)
	set_rot(-angle+PI/2)
	set_fixed_process(true)

func _fixed_process(delta):
	set_pos(get_pos()+(Vector2(cos(angle), sin(angle))*speed))
	for body in get_overlapping_bodies():
		if body.get_name() != "Forest":
			set_fixed_process(false)
			if body.get_name() == "player":
				if not (body.protecting or body.dodging):
					body.damage(4)
			get_node("AnimationPlayer").play("destroy")
			return