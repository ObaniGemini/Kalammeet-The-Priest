extends Node2D

const branch_cl = preload("res://Scenes/Decor/tree_branch.tscn")
const n_max = 2
const LENGTH = 8
onready var anim = Animation.new()

func _ready():
	randomize()
	anim.set_loop(true)
	anim.set_length(LENGTH)
	for i in range((randi() % 3)+4):
		add_branches(get_node("branches"))
	get_node("AnimationPlayer").add_animation("idle", anim)
	get_node("AnimationPlayer").play("idle")
	get_node("AnimationPlayer").set_speed(rand_range(1, 2))

func add_branches(parent, n=n_max):
	for i in range((randi() % 2)+2):
		var branch = branch_cl.instance()
		parent.add_child(branch)
		var rot = (((randi() % 7)-3)*20)+randi()%6
		var scale = Vector2(rand_range(0.4, 0.5), rand_range(0.4, 0.5))
		var pos = Vector2(0, ((randi() % 128))*(1/(2*scale.y)))
		branch.set_scale(scale)
		branch.set_pos(pos)
		if n==n_max:
			anim.add_track(0, 0)
			anim.track_insert_key(0, 0, rot+180, 1)
			anim.track_insert_key(0, rand_range(2, 3), rot+180+sign(rot)*4, 1)
			anim.track_set_interpolation_type(0, 1)
			anim.track_set_path(0, str(branch.get_path())+":transform/rot")
		else:
			branch.set_rotd(rot)
		if n!=0:
			add_branches(branch, n-1)