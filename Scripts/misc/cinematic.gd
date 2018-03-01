extends CanvasLayer

export var next_scene = ""
var playing = false

func _ready():
	set_fixed_process(true)

func quit():
	get_tree().change_scene_to(load(next_scene))

func _fixed_process(delta):
	if not get_node("AnimationPlayer").is_playing() and playing:
		get_node("AnimationPlayer").play("quit")
		get_node("AnimationPlayer").connect("finished", self, "quit")
		set_fixed_process(false)
	elif Input.is_action_pressed("summon"):
		if not playing:
			playing = true
			get_node("AnimationPlayer").play("skip")
			get_node("Node2D").show()
	elif playing:
		playing = false
		get_node("AnimationPlayer").stop()
		get_node("Node2D").hide()