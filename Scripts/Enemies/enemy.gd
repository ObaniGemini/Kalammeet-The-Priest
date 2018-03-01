extends KinematicBody2D

const MOVING_SPEED = 64
const GRAVITY = 8
const SIZE = 650

const anim_factors = {
	"attack" : 1
}

var vel = Vector2(0, 0)

var attacking = false
var protecting = false
var dodging = false
var dead = false

var running = 0

export var damage = 1
export var health = 20
export var exp_value = 1
export var cooldown = 1.0
export var running_time = 100

onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var player = get_node("../player")
onready var weapon = get_node("Body/Torso/Arms/up_r/Sprite/handler/Area2D")

func anim_started(name):
	if name == "attack":
		weapon.factor = anim_factors[name]


func _ready():
	hide()
	timer.set_wait_time(cooldown)
	for body in get_node("Area2D").get_overlapping_bodies():
		if body.get_name() == "player":
			get_node("Area2D").connect("body_exit", self, "spawn")
			return
	spawn()


func damage(value, side):
	if dead:
		return
	protecting = true
	health -= value
	var tween = player.get_node("Camera2D/Tween")
	tween.interpolate_property(tween.get_parent(), "transform/rot", sign(rand_range(-1, 1))*damage/2, 0, 0.2, 9, 1)
	tween.start()
	if health <= 0:
		set_fixed_process(false)
		dead = true
		play("die")
		get_node("SamplePlayer").play("chinese_dead_"+str(randi()%2+1))
		player.add_exp(exp_value)
		return
	play("damage")
	yield(anim, "finished")
	protecting = false
	if not is_fixed_processing():
		set_fixed_process(true)


func spawn(body=null):
	if body != null:
		if body.get_name() != "player":
			return
	show()
	get_node("SamplePlayer").play("chinese_"+str(randi()%2+1))
	set_fixed_process(true)


func play(track):
	if not is_playing(track):
		anim.play(track)
		if track != "attack":
			weapon.factor = 0

func is_playing(track):
	return anim.is_playing() and anim.get_current_animation() == track

func cooldown():
	if anim.get_current_animation() == "attack":
		weapon.factor = 0
		attacking = false
		set_fixed_process(false)
		timer.start()
		yield(timer, "timeout")
		set_fixed_process(true)


func _fixed_process(delta):
	if dead:
		set_fixed_process(false)
		return
	var comparison = Vector2(get_pos().x - player.get_pos().x, get_pos().y - player.get_pos().y + SIZE/2)
	var side = 0
	
	vel.y += GRAVITY
	
	if abs(comparison.x) < 500 and abs(comparison.y) < 2000:
		set_fixed_process(false)
		attacking = true
		play("attack")
	else:
		if sign(-comparison.x) != side:
			get_node("Body").set_scale(Vector2(sign(-comparison.x), 1))
		side = sign(-comparison.x)
		play("run")
	
	if side == -1 and get_node("check_left").is_colliding():
		side = 0
	elif side == 1 and get_node("check_right").is_colliding():
		side = 0
	
	vel.x = side*MOVING_SPEED
	
	for ray in get_node("check_down").get_children():
		if ray.is_colliding():
			set_pos(Vector2(get_pos().x, ray.get_collider().get_pos().y-SIZE))
			vel.y = 0
			break
	
	
	move(vel)
	
	if not is_playing("damage"):
		running += 1
	if running >= running_time:
		set_fixed_process(false)
		idle()


func idle():
	play("idle")
	get_node("run").set_wait_time(rand_range(1, 1.5))
	get_node("run").start()
	yield(get_node("run"), "timeout")
	running = 0
	set_fixed_process(true)