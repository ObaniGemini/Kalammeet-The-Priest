extends Node2D

var buttons = []
var focused = ""
var need_confirm = false
onready var cur_tab = get_node("buttons/main")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		quit()

func set_fullscreen():
	if save_manager.config["fullscreen"]:
		get_node("buttons/options/Fullscreen/Label").set_text("Windowed")
	else:
		get_node("buttons/options/Fullscreen/Label").set_text("Fullscreen")
	OS.set_window_fullscreen(save_manager.config["fullscreen"])

func set_sound():
	if save_manager.config["sound"]:
		get_node("buttons/options/Sound/Label").set_text("Sound : Off")
		AudioServer.set_stream_global_volume_scale(1.0)
	else:
		get_node("buttons/options/Sound/Label").set_text("Sound : On")
		AudioServer.set_stream_global_volume_scale(0.0)

func _ready():
	get_node("StreamPlayer").fade_in(2)
	update_tab(0)
	set_fullscreen()
	set_sound()
	check_saves()
	get_node("Tween").interpolate_property(get_node("Sprite"), "modulate", Color(0, 0, 0), Color(1, 1, 1), 1.5, 0, 1)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_node("Tween").interpolate_property(get_node("Sprite"), "visibility/opacity", 1, 0, 1.5, 0, 1)
	get_node("Tween").start()
	set_process_input(true)

func check_saves():
	var save = [save_manager.get_save(1), save_manager.get_save(2)]
	if save[0] != null:
		get_node("buttons/saves/Save1/Map").set_text(save[0]["map"])
		get_node("buttons/saves/Save1/Level").set_text("Level "+str(save[0]["level"]))
		get_node("buttons/saves/Save1/exp").set_scale(Vector2(768*(float(save[0]["exp"])/int(save[0]["level"]*2)), 16))
		get_node("buttons/saves/Save1/exp").show()
		get_node("buttons/saves/Save1/Map").show()
		get_node("buttons/saves/Save1/Level").show()
		get_node("buttons/saves/Save1/State").hide()
	else:
		get_node("buttons/saves/Save1/Map").hide()
		get_node("buttons/saves/Save1/Level").hide()
		get_node("buttons/saves/Save1/exp").hide()
		get_node("buttons/saves/Save1/State").show()
	if save[1] != null:
		get_node("buttons/saves/Save2/Map").set_text(save[1]["map"])
		get_node("buttons/saves/Save2/Level").set_text("Level "+str(save[1]["level"]))
		get_node("buttons/saves/Save2/exp").set_scale(Vector2(768*(float(save[1]["exp"])/int(save[1]["level"]*2)), 16))
		get_node("buttons/saves/Save2/exp").show()
		get_node("buttons/saves/Save2/Map").show()
		get_node("buttons/saves/Save2/Level").show()
		get_node("buttons/saves/Save2/State").hide()
	else:
		get_node("buttons/saves/Save2/Map").hide()
		get_node("buttons/saves/Save2/exp").hide()
		get_node("buttons/saves/Save2/Level").hide()
		get_node("buttons/saves/Save2/State").show()

func update_tab(index):
	var new_tab = get_node("buttons").get_child(index)
	if new_tab.get_name() != cur_tab.get_name():
		get_node("buttons/Tween1").stop_all()
		get_node("buttons/Tween1").interpolate_property(cur_tab, "transform/pos", cur_tab.get_pos(), Vector2(-512, 0), 0.4, 1, 1)
		get_node("buttons/Tween1").start()
		get_node("buttons/Tween2").stop_all()
		get_node("buttons/Tween2").interpolate_property(new_tab, "transform/pos", new_tab.get_pos(), Vector2(0, 0), 0.4, 1, 1)
		get_node("buttons/Tween2").start()
	for button in buttons:
		button.unhover()
	cur_tab = new_tab
	buttons = cur_tab.get_children()
	focus(0)

func focus(value):
	var index = 0
	for button in buttons:
		if button.hovered:
			button.unhover()
			index = buttons.find(button)
			break
	index += value
	var size = (buttons.size() - 1)
	if index > size:
		index = 0
	elif index < 0:
		index = size
	buttons[index].hover()
	focused = buttons[index].get_name()
	if need_confirm:
		get_node("warning").hide()
		need_confirm = false

func _input(event):
	if event.is_action_pressed("ui_up"):
		focus(-1)
	elif event.is_action_pressed("ui_down"):
		focus(1)
	elif event.is_action_pressed("jump"):
		if focused == "Load":
			update_tab(2)
		elif focused == "Options":
			update_tab(1)
		elif focused == "Quit":
			quit()
		elif focused == "Fullscreen":
			save_manager.switch_config("fullscreen")
			set_fullscreen()
		elif focused == "Sound":
			save_manager.switch_config("sound")
			set_sound()
		elif focused == "Back":
			update_tab(0)
		elif focused.find("Save") != -1:
			if need_confirm:
				need_confirm = false
				save_manager.erase_save(int(focused.substr(4, 1)))
				check_saves()
				get_node("warning").hide()
			else:
				save_manager.save = int(focused.substr(4, 1))
				save_manager.load_game()
				set_process_input(false)
				start()
				get_node("StreamPlayer").fade_out(2)
	elif event.is_action_pressed("summon"):
		if focused.find("Save") != -1:
			if need_confirm:
				need_confirm = false
				get_node("warning").hide()
			else:
				if save_manager.get_save(int(focused.substr(4, 1))) != null:
					need_confirm = true
					get_node("warning").show()
	elif event.is_action_pressed("exit"):
		if cur_tab.get_name() != "main":
			update_tab(0)
		else:
			quit()

func start():
	get_node("Tween").stop_all()
	get_node("Tween").interpolate_property(get_node("Sprite"), "visibility/opacity", get_node("Sprite").get_opacity(), 1, 1.5, 0, 1)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_node("Tween").interpolate_property(get_node("Sprite"), "modulate", Color(1, 1, 1), Color(0, 0, 0), 2, 0, 1)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_tree().change_scene_to(load("res://Scenes/game.tscn"))

func quit():
	set_process_input(false)
	get_node("StreamPlayer").fade_out(0.5)
	get_node("AnimationPlayer").play("exit")
	get_node("AnimationPlayer").connect("finished", get_tree(), "quit", [], 4)