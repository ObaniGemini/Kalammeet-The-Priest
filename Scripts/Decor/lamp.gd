extends Area2D

var shown = true

func _on_body_enter(body):
	if body.get_name() == "player" and shown:
		shown = false
		get_node("AnimationPlayer").play("disable")

func _on_body_exit(body):
	if body.get_name() == "player" and not shown:
		shown = true
		get_node("AnimationPlayer").play("enable")