extends Area2D

export var text = ""
export var id = -1

func _ready():
	connect("body_enter", self, "_on_body_enter")

func _on_body_enter(body):
	if body.get_name() == "player":
		body.announcer("info", text, Color(1, 1, 1), 1.1, id)
		disconnect("body_enter", self, "_on_body_enter")
		queue_free()
