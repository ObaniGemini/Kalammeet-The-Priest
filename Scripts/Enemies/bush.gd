extends Area2D

const bandits = preload("res://Scenes/Enemies/Bandits.tscn")

func _ready():
	get_node("AnimatedSprite").set_frame(randi()%3)
	get_node("AnimationPlayer").set_speed(rand_range(0.5, 1))

func _on_body_enter(body):
	if body.get_name() == "player":
		disconnect("body_enter", self, "_on_body_enter")
		var bandit = bandits.instance()
		bandit.set_global_pos(get_pos()+Vector2(0, -512))
		get_parent().add_child(bandit)
		get_node("AnimationPlayer").play("destroy")
		get_node("AnimationPlayer").connect("finished", self, "queue_free")
		bandit.idle()