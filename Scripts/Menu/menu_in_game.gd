extends Node2D

onready var anim = get_node("AnimationPlayer")
onready var player = get_node("../../")
onready var buttons = get_node("Chains/buttons").get_children()
var focused = ""

var shown = false
var shown_summons = false
var quitting = false
var summons = []
var n = 0

func reset_summons():
	for object in get_node("Chains/summons").get_children():
		object.queue_free()

func add_summon(list):
	var hbox = HBoxContainer.new()
	hbox.set_custom_minimum_size(Vector2(480, 110))
	for name in list:
		var control = Control.new()
		control.set_custom_minimum_size(Vector2(110, 90))
		control.add_child(get_node("icons/"+name).duplicate())
		hbox.add_child(control)
	get_node("Chains/summons").add_child(hbox)

func update_summons(N):
	reset_summons()
	if summons.size() > 6:
		n += N
		if n == summons.size()-1 or n == -summons.size()+1:
			n = 0
		for i in range(6):
			if n+i >= summons.size():
				add_summon(summons[n+i-summons.size()])
			else:
				add_summon(summons[n+i])
	else:
		for summon in summons:
			add_summon(summon)

func _ready():
	set_process_input(true)

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

func show_menu():
	if shown:
		reset_summons()
		summons.clear()
		anim.play("leave")
		chain_go(Vector2(0, -2048))
	else:
		anim.play("enter")
		chain_go(Vector2(0, -1024))
		for i in range(player.summons.size()):
			if save_manager.progression["combos"][i]:
				summons.append(player.summons[i])
		update_summons(0)
		focus(0)
	player.can_move = shown
	shown = !shown

func show_summons():
	if shown_summons:
		chain_go(Vector2(0, -1024))
	else:
		chain_go(Vector2(0, 0))
	shown_summons = !shown_summons

func _input(event):
	if not anim.is_playing() or quitting:
		if event.is_action_pressed("escape"):
			if shown_summons:
				show_summons()
			else:
				show_menu()
		elif shown:
			if event.is_action_pressed("ui_up"):
				if shown_summons:
					update_summons(-1)
				else:
					focus(-1)
			elif event.is_action_pressed("ui_down"):
				if shown_summons:
					update_summons(1)
				else:
					focus(1)
			elif event.is_action_pressed("jump") and not shown_summons:
				if focused == "Continue":
					show_menu()
				elif focused == "Summons":
					show_summons()
				elif focused == "Quit":
					quitting = true
					get_node("/root/game").quit()

func chain_go(pos):
	get_node("Tween").stop_all()
	get_node("Tween").interpolate_property(get_node("Chains"), "transform/pos", get_node("Chains").get_pos(), pos, 0.2, 9, 1)
	get_node("Tween").start()