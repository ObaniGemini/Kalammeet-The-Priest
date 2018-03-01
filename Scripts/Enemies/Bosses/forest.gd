extends KinematicBody2D

const projectile_class = preload("res://Scenes/Enemies/Bosses/projectile.tscn")
const max_health = 2000
const exp_worth = 200

onready var player = get_node("../player")
onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")

var health = max_health
var playing = false
var dead = false

var attacking = false
var protecting = false
var dodging = false
var stage = 0

func _ready():
	for node in get_node("../spikes").get_children():
		if node extends Node2D:
			node.get_node("Area2D").factor = 1
	set_process(true)

func pattern1():
	if stage == 3:
		return
	timer.set_wait_time(0.05+float(health/16)/max_health)
	for i in range(32):
		projectile(11*i, 60*2-(float(health)/max_health))
		timer.start()
		yield(timer, "timeout")
	pattern2()

func pattern2():
	if stage == 3:
		return
	timer.set_wait_time(0.05+float(health/16)/max_health)
	for i in range(8):
		for j in range(4):
			projectile(45*i+90*j, 60*2-(float(health)/max_health))
		timer.start()
		yield(timer, "timeout")
	pattern1()

func projectile(angle, speed):
	var proj = projectile_class.instance()
	proj.angle = deg2rad(angle)
	add_child(proj)
	get_node("SamplePlayer2D").play("throw")

func die():
	get_node("AnimationPlayer").disconnect("finished", self, "set")
	set_process(false)
	stage = 3
	player.add_exp(exp_worth)
	get_node("AnimationPlayer").play("die")
	get_node("SamplePlayer2D").play("death"+str(randi()%3+1))
	get_node("../Timer").queue_free()
	get_node("../Timer1").queue_free()
	get_node("../spikes/AnimationPlayer").stop()
	for node in get_node("../spikes").get_children():
		if node extends Node2D:
			node.set_pos(Vector2(node.get_pos().x, 1024))
	get_node("/root/game").end()

func damage(hp, side):
	if not protecting:
		protecting = true
		if health <= hp:
			die()
			return
		health -= hp
		var damage = anim.get_animation("damage")
		for i in range(5):
			damage.track_set_key_value(6+i, 1, Color(1, float(health)/max_health, float(health)/max_health))
		anim.remove_animation("damage")
		anim.add_animation("damage", damage)
		anim.play("damage")
		get_node("SamplePlayer2D").play("damage"+str(randi()%5+1))
		get_node("../tree/AnimationPlayer").play("damage")
		get_node("eye/inner/AnimationPlayer").set_speed(1+8-float(health)/(max_health/4))

func _process(delta):
	if not playing:
		var pos = (Vector2(get_global_pos().x-player.get_global_pos().x, get_global_pos().y-player.get_global_pos().y-128)).normalized()
		get_node("eye/Sprite").set_pos(Vector2(-pos.x, -pos.y)*24)
	if health <= max_health*0.75 and stage == 0:
		stage = 1
		pattern1()
	elif health <= max_health*0.4 and stage == 1:
		stage = 2
		get_node("../spikes/AnimationPlayer").play("pattern3")