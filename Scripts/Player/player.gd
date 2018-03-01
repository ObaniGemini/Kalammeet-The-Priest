extends KinematicBody2D

const announcer_class = preload("res://Scenes/misc/announcer.tscn")

const hand = preload("res://Scenes/Player/weapons/hand.tscn")
const dagger = preload("res://Scenes/Player/weapons/dagger.tscn")
const sword = preload("res://Scenes/Player/weapons/sword.tscn")
const axe = preload("res://Scenes/Player/weapons/axe.tscn")
const power = preload("res://Scenes/Player/weapons/power.tscn")
const fire = preload("res://Scenes/Player/weapons/fire.tscn")
const bo = preload("res://Scenes/Player/weapons/bo.tscn")
const double_blade = preload("res://Scenes/Player/weapons/double_blade.tscn")

const MOVING_SPEED = 96
const DODGING_SPEED = 64
const GRAVITY = 8

const anim_factors = {
	"hit1" : 1,
	"hit2" : 1,
	"hit3" : 1.2
}

const keys = {
	"jump" : preload("res://Scenes/PS/Cross.tscn"),
	"hit" : preload("res://Scenes/PS/Square.tscn"),
	"summon" : preload("res://Scenes/PS/Triangle.tscn"),
	"kick" : preload("res://Scenes/PS/Circle.tscn")
}

const summons = [
	["summon"], ["kick", "kick"], ["hit", "hit"], ["jump", "jump"], \
	["kick", "hit"], ["kick", "jump"], ["kick", "summon"], \
	["jump", "summon", "jump"], ["jump", "kick", "hit"], \
	["jump", "summon", "hit"], ["hit", "kick", "jump"], \
	["hit", "summon", "kick", "jump"], ["hit", "kick", "summon", "jump"]
]

const weapons = [
	[null, sword], [dagger, dagger], [axe, axe], [bo, bo], \
	[power, power], [power, power], [power, power], \
	[double_blade, double_blade], [fire, fire], \
	[fire, fire], [fire, fire], \
	[fire, fire], [fire, fire], \
]


var summon = []
var vel = Vector2(0, 0)
var side = 1

var can_move = true

var attacking = false
var damaged = false
var jumping = false
var double_jumped = false
var crounched = false
var summoning = false
var protecting = false
var dodging = false

var health_max = 40
var health = 0
var mana_max = 250
var mana = 0
var mana_cooldown = 2
var exp_max = 4
var damage = 1

var combo = 0

onready var down_ray = get_node("check_down")
onready var up_ray = get_node("check_up")
onready var left_ray = get_node("check_left")
onready var right_ray = get_node("check_right")

onready var anim = get_node("AnimationPlayer")
onready var handlers = [get_node("Body/Torso/Arms/up_l/Sprite/handler"), get_node("Body/Torso/Arms/up_r/Sprite/handler")]
onready var camera = get_node("Camera2D")

func announcer(anim, text, color, speed=1, id=-1):
	var a = announcer_class.instance()
	get_node("CanvasLayer").add_child(a)
	a.announce(anim, text, color, speed, id)

func anim_started(name):
	for handler in handlers:
		for weapon in handler.get_children():
			if weapon != null:
				if name.find("hit") != -1:
					weapon.factor = anim_factors[name]
				else:
					weapon.factor = 0

func update_limit():
	camera.set_limit(0, get_node("../camera_begin").get_pos().x)
	camera.set_limit(1, get_node("../camera_begin").get_pos().y)
	camera.set_limit(2, get_node("../camera_end").get_pos().x)
	camera.set_limit(3, get_node("../camera_end").get_pos().y)

func _ready():
	update_limit()
	get_node("CanvasLayer/exp/Tween").connect("tween_complete", self, "check_exp")
	update_values()
	for handler in handlers:
		var h = hand.instance()
		h.user_damage = damage
		handler.add_child(hand.instance())
	set_fixed_process(true)
	set_process_input(true)

func add_level():
	save_manager.add("level", 1)
	save_manager.add("exp", -exp_max)
	announcer("enter", "Level Up !", Color(rand_range(0, 1), 0.5, 1))
	update_values()

func update_values():
	var lvl = save_manager.progression["level"]
	get_node("regen").set_wait_time((20.0)/(lvl + 10.0))
	damage = 1+lvl*0.125
	health_max = 40+lvl*10
	health = health_max
	mana_max = lvl*50+300
	mana = mana_max
	mana_cooldown = 2+int(lvl*0.6)
	exp_max = int(lvl*2)
	get_node("CanvasLayer/exp").set_value(0)
	update_mana()
	update_hp()
	check_exp()

func update_mana():
	get_node("CanvasLayer/mana").set_max(mana_max)
	get_node("CanvasLayer/mana").tween(mana)
	get_node("CanvasLayer/mana/AnimationPlayer").play("use")

func update_hp():
	get_node("CanvasLayer/health").set_max(health_max)
	get_node("CanvasLayer/health").tween(health)
	get_node("CanvasLayer/health/max_hp").set_text(str(health_max))
	get_node("CanvasLayer/health/hp").set_text(str(health))

func check_exp(object=null, key=null):
	if save_manager.progression["exp"] >= exp_max:
		add_level()
	else:
		get_node("CanvasLayer/exp").set_max(exp_max)
		get_node("CanvasLayer/exp").tween(save_manager.progression["exp"])

func add_exp(value):
	save_manager.add("exp", value)
	check_exp()

func use_mana(value):
	if mana >= value:
		mana -= value
	else:
		mana = 0
		if summoning:
			quit_summon(false)
		announcer("warning", "No Mana !", Color(rand_range(0.8, 1), rand_range(0, 0.2), 0))
	update_mana()

func regen_hp():
	if health < health_max:
		health += 1
		update_hp()
	get_node("regen").start()

func damage(hp, side=1):
	protecting = true
	health -= hp
	if health < 0: health = 0
	if health == 0:
		can_move = false
		get_node("/root/game").leave_level(save_manager.progression["map"])
		set_fixed_process(false)
		return
	
	anim.play("damage"+str(randi() % 2 + 1))
	damaged = true
	update_hp()
	var d_anim = get_node("Camera2D/AnimationPlayer").get_animation("damage")
	d_anim.track_set_key_value(0, 0, -damage)
	d_anim.track_set_key_value(0, 1, damage*0.5)
	d_anim.track_set_key_value(0, 2, -damage*0.25)
	d_anim.track_set_key_value(2, 0, 0.25+(damage/100))
	get_node("Camera2D/AnimationPlayer").remove_animation("damage")
	get_node("Camera2D/AnimationPlayer").add_animation("damage", d_anim)
	get_node("Camera2D/AnimationPlayer").play("damage")
	yield(anim, "finished")
	protecting = false

#################---FIXED PROCESS---#################

func _fixed_process(delta):
	var new_side = 0
	vel.x = 0
	vel.y += GRAVITY
	
	var shape_y = get_shape(0).get_extents().y
	if dodging and shape_y != 192:
		set_shape(0, get_node("dodge_shape").get_shape())
		left_ray.set_cast_to(Vector2(0, -384))
		right_ray.set_cast_to(Vector2(0, -384))
		up_ray.set_pos(Vector2(-248, 286))
	elif not dodging and shape_y == 192:
		set_shape(0, get_node("shape").get_shape())
		left_ray.set_cast_to(Vector2(0, -736))
		right_ray.set_cast_to(Vector2(0, -736))
		up_ray.set_pos(Vector2(-248, -66))
	
	if down_ray.is_colliding() and vel.y > 0:
		vel.y = 0
		jumping = false
		double_jumped = false
	if up_ray.is_colliding() and vel.y < 0:
		vel.y = 0
	
	if can_move:
		if Input.is_action_pressed("left"): new_side -= 1
		if Input.is_action_pressed("right"): new_side += 1
	
	if not (anim.is_playing() and (damaged or protecting or attacking or dodging)):
		go_on_side(new_side)
	elif (not dodging or damaged):
		side = 0
	
	if (left_ray.is_colliding() and (-1 in [side, new_side]) and left_ray.get_collider().get_rot() == 0) or (right_ray.is_colliding() and (1 in [side, new_side]) and right_ray.get_collider().get_rot() == 0):
		side = 0
	
	
	if dodging:
		if jumping: vel.x = side*DODGING_SPEED*2
		else: vel.x = side*DODGING_SPEED
	else:
		vel.x = side*MOVING_SPEED
	
	if is_colliding():
		var n = get_collision_normal()
		vel = n.slide(vel)
		if jumping:
			jumping = false
			double_jumped = false
	
	move(vel)
	
	if mana >= mana_max:
		mana = mana_max
		if not get_node("CanvasLayer/mana/AnimationPlayer").is_playing():
			get_node("CanvasLayer/mana/AnimationPlayer").play("full")
	else:
		if not get_node("CanvasLayer/mana").active:
			mana += mana_cooldown
			get_node("CanvasLayer/mana").set_value(mana)




func go_on_side(new_side):
	combo = 0
	damaged = false
	protecting = false
	attacking = false
	dodging = false
	var cur_anim = anim.get_current_animation()
	if new_side != 0:
		if new_side != side:
			get_node("Body").set_scale(Vector2(new_side, 1))
			camera_to(Vector2(768*new_side,0))
		if not anim.is_playing() or cur_anim != "run" and not jumping:
			anim.play("run")
	else:
		if not jumping:
			if not anim.is_playing() or (not crounched and cur_anim != "idle"): anim.play("idle")
			elif not anim.is_playing() or (crounched and cur_anim != "crounch"): anim.play("crounch")
	side = new_side


func camera_to(pos):
	get_node("Tween").stop_all()
	get_node("Tween").interpolate_property(camera, "offset", camera.get_offset(), pos, 0.75, 2, 1)
	get_node("Tween").start()

func summon_sound():
	if summoning:
		get_node("Node/summon"+str(randi()%3 + 1)).play()

func start_summon():
	summoning = true
	protecting = false
	attacking = false
	dodging = false
	set_fixed_process(false)
	get_node("CanvasLayer/Tween").stop_all()
	get_node("CanvasLayer/Tween").interpolate_property(get_node("CanvasLayer/Sprite"), "visibility/opacity", get_node("CanvasLayer/Sprite").get_opacity(), 0.5, 0.5, 1, 1)
	get_node("CanvasLayer/Tween").start()
	anim.play("summon")
	get_node("SamplePlayer").play("invoc_1")
	summon_sound()
	for handler in handlers:
		for weapon in handler.get_children():
			weapon.destroy()
	camera_to(Vector2(0, -256))
	vel.y = 0

func add_summon(action):
	summon.append(action)
	var indicator = keys[action].instance()
	indicator.set_pos(Vector2(640, 360))
	get_node("CanvasLayer").add_child(indicator)
	use_mana(250)
	if not summoning:
		return
	
	for list in summons:
		if summon == list:
			var idx = summons.find(list)
			if weapons[idx][0] != null:
				handlers[0].add_child(weapons[idx][0].instance())
				handlers[0].get_child(0).user_damage = damage
			handlers[1].add_child(weapons[idx][1].instance())
			handlers[1].get_child(0).user_damage = damage
			if not save_manager.progression["combos"][idx]:
				save_manager.progression["combos"][idx] = true
				announcer("enter", "New summon !", Color(1, 1, 1))
			quit_summon(true)
			break
	
	if summon.size() >= 5:
		print("didn't find it bro")
		quit_summon(false)

func quit_summon(found, new_side=0):
	summon = []
	summoning = false
	jumping = false
	if new_side == 0:
		new_side = get_node("Body").get_scale().x
	if not found:
		for handler in handlers:
			var h = hand.instance()
			h.user_damage = damage
			handler.add_child(hand.instance())
	set_fixed_process(true)
	get_node("CanvasLayer/Tween").stop_all()
	get_node("CanvasLayer/Tween").interpolate_property(get_node("CanvasLayer/Sprite"), "visibility/opacity", get_node("CanvasLayer/Sprite").get_opacity(), 0, 0.5, 1, 1)
	get_node("CanvasLayer/Tween").start()
	camera_to(Vector2(768*new_side, 0))


#################---INPUT---#################

func _input(event):
	if not can_move:
		return
	
	if summoning:
		for action in ["jump", "hit", "kick", "summon"]:
			if event.is_action_pressed(action):
				add_summon(action)
		
		if event.is_action_pressed("left"):
			quit_summon(false, -1)
		elif event.is_action_pressed("right"):
			quit_summon(false, 1)
	else:
		if event.is_action_pressed("jump") and (down_ray.is_colliding() and not (jumping or crounched) or not double_jumped):
			if jumping:
				double_jumped = true
			anim.play("jump")
			vel.y = -128
			jumping = true
			protecting = false
			dodging = false
		if event.is_action_pressed("summon"):
			start_summon()
		for attack in ["hit", "kick"]:
			if event.is_action_pressed(attack) and not (protecting or dodging):
				attack(attack)
	
	if not dodging:
		action_rl(event, "protect", "protecting")
	if event.is_action_pressed("crounch") and not (crounched or protecting or jumping or dodging):
		crounched = true
		protecting = false
		override_summon("crounch")
		camera_to(Vector2(side*768, 512))
	elif event.is_action_released("crounch") and crounched:
		crounched = false
		camera_to(Vector2(camera.get_offset().x, 0))
	if not damaged:
		damaged = false
		action_rl(event, "dodge", "dodging")

func action_rl(event, act, cond):
	var i = -3
	for action in [act+"_left", act+"_right"]:
		i += 2
		if event.is_action_pressed(action) and not get(cond):
			set(cond, true)
			override_summon(act)
			get_node("Body").set_scale(Vector2(i, 1))
			camera_to(Vector2(768*i,0))
			side = i


func override_summon(title):
	if summoning:
		quit_summon(false)
	anim.play(title)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		set_fixed_process(false)
		set_process_input(false)
		get_tree().quit()


func attack(type):
	if not attacking:
		combo = 1
		attacking = true
		anim.play("hit1")
	else:
		if anim.get_current_animation() == ("hit"+str(combo)):
			combo += 1
		if combo <= 3:
			anim.queue("hit"+str(combo))