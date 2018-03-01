extends Node2D

var scene = null

func switch_music(map):
	var to_play = ""
	if map in ["street", "houses", "elevator", "cave", "cave2", "sunlight", "shelter"]:
		to_play = "Leave"
	elif map == "none":
		to_play = "none"
	else:
		to_play = "Forest"
	
	for music in get_node("Musics").get_children():
		if music.is_playing():
			if music.get_name() == to_play:
				return
			music.fade_out(2)
			break
	if to_play != "none":
		get_node("Musics/"+to_play).fade_in(2)

func stop_ambiences():
	for ambience in get_node("Ambiences").get_children():
		if ambience.is_playing():
			ambience.fade_out(1.5)

func _ready():
	load_level(save_manager.progression["map"])

func load_scene(path):
	scene = load(path)
	for node in get_node("scene").get_children():
		node.queue_free()
	get_node("scene").add_child(scene.instance())
	get_node("Transition").play("enter")
	if path == "res://Scenes/Cinematics/intro.tscn":
		yield(get_node("scene/intro").get_node("AnimationPlayer"), "finished")
		quit()

func load_level(level_name):
	load_scene("res://Scenes/Levels/"+level_name+".tscn")
	save_manager.update_state("map", level_name)
	if level_name in ["street", "houses", "elevator"]:
		get_node("Ambiences/Rain").fade_in(1.5)
	switch_music(level_name)

func load_cinematic(cinematic_name, idx):
	load_scene("res://Scenes/Cinematics/"+cinematic_name+".tscn")
	save_manager.progression["cinematics"][idx] = true

func leave_level(next_level):
	stop_ambiences()
	get_node("Transition").play("leave")
	get_node("Transition").connect("finished", self, "load_level", [next_level], 4)

func quit():
	get_node("enter").play("quit")
	yield(get_node("enter"), "finished")
	for c in get_node("scene").get_children():
		c.queue_free()
	get_tree().change_scene_to(load("res://Scenes/Menu/menu.tscn"))

func end():
	get_node("end").play("end")
	switch_music("none")
	yield(get_node("end"), "finished")
	load_cinematic("intro", 0)