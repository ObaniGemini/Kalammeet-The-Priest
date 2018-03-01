extends Area2D

export var level = ""

func _on_body_enter(body):
	if body.get_name() == "player":
		body.can_move = false
		get_node("/root/game").leave_level(level)
		disconnect("body_enter", self, "_on_body_enter")