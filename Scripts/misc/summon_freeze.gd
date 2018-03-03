extends Area2D

func _ready():
	connect("body_enter", self, "_on_body_enter")
	connect("body_exit", self, "_on_body_exit")

func _on_body_enter(body):
	if body.get_name() == "player":
		body.can_summon = false

func _on_body_exit(body):
	if body.get_name() == "player":
		body.can_summon = true