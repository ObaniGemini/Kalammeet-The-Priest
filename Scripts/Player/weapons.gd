extends Area2D

const label = preload("res://Scenes/misc/damage_label.tscn")

export var damage = 1.0
export var group = "enemies"
export var can_parry = true
export var can_dodge = true
var user_damage = 1.0
var factor = 0

func _ready():
	set_fixed_process(true)

func destroy():
	if has_node("AnimationPlayer") and not get_node("AnimationPlayer").is_playing():
		get_node("AnimationPlayer").play("exit")
		get_node("AnimationPlayer").connect("finished", self, "queue_free", [], 4)
	else:
		queue_free()

func _fixed_process(delta):
	if factor != 0:
		for body in get_overlapping_bodies():
			if body.is_in_group(group):
				if (not (can_parry and body.protecting) and not (can_dodge and body.dodging)) and (damage+user_damage) != 0:
					var final_damage = int(damage*user_damage*factor)
					var side = sign(body.get_global_pos().x - get_global_pos().x)
					body.damage(final_damage, side)
					if has_node("SamplePlayer"):
						if not get_node("SamplePlayer").is_active():
							get_node("SamplePlayer").play("hit")
					if not body extends RigidBody2D:
						var d_label = label.instance()
						d_label.start(final_damage, body.get_pos(), group)
						get_node("/root/game").add_child(d_label)