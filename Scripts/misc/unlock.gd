extends Node2D

func _on_body_enter(body):
	if body.get_name() == "player":
		get_node("lock").disconnect("body_enter", self, "_on_body_enter")
		get_node("lock/AnimationPlayer").play("lock")
		yield(get_node("lock/AnimationPlayer"), "finished")
		get_node("player").update_limit()
		set_fixed_process(true)

func _fixed_process(delta):
	for node in get_children():
		if node.is_in_group("enemies") or node.is_in_group("spawner"):
			if node.get("dead") != null:
				if not node.get("dead"):
					return
			else:
				return
	set_fixed_process(false)
	get_node("lock/AnimationPlayer").play("unlock")
	yield(get_node("lock/AnimationPlayer"), "finished")
	get_node("player").update_limit()