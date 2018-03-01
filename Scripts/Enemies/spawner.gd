extends Timer

export (PackedScene) var enemy
export var pos1 = Vector2(0, 0)
export var pos2 = Vector2(0, 0)
export var n = 1

func spawn(body=null):
	var pos
	if n == -1:
		pos = Vector2(rand_range(pos1.x, pos2.x), pos1.y)
	else:
		pos = get_node("../player").get_pos()
		if pos.distance_to(pos1) > pos.distance_to(pos2):
			pos = pos1
		else:
			pos = pos2
	var spawned = enemy.instance()
	spawned.set_pos(pos)
	if n == -1:
		spawned.angle = PI/2
		spawned.speed = 30
	get_parent().add_child(spawned)
	if n > 0:
		n -= 1
	if n == 0:
		queue_free()
	else:
		start()