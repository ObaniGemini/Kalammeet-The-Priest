extends Node

const default_config = {
	"fullscreen" : false,
	"sound" : true
}

const starting_state = {
	"map" : "street",
	"level" : 1,
	"exp" : 0,
	"combos" : [false, false, false, false, false, false, false, false, false, false, false, false, false],
	"cinematics" : [false]
}

var config = {}
var progression = {}
var save = 0

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()

func update_state(key, value):
	var old_val = progression[key] 
	progression[key] = value
	save_game()
	print(key+" updated from "+str(old_val)+" to "+str(value))

func add(key, value):
	update_state(key, progression[key]+value)

func is(key, value):
	return progression[key] == value

func get_save(value):
	var f = File.new()
	var err = f.open_encrypted_with_pass("res://game_"+str(value)+".save", File.READ, "Kalammeet")
	
	if !err:
		return f.get_var()

func erase_save(value):
	var f = File.new()
	var err = f.open_encrypted_with_pass("res://game_"+str(value)+".save", File.WRITE, "Kalammeet")
	f.store_var(null)
	f.close()

func _ready():
	load_config()
	if config["fullscreen"]:
		OS.set_window_fullscreen(true)

func switch_config(key):
	config[key] = !config[key]
	save_config()

func load_config():
	var f = File.new()
	var err = f.open_encrypted_with_pass("res://config.save", File.READ, "Kalammeet")
	
	if !err:
		config = f.get_var()
	
	if config == null:
		config = default_config
	else:
		for option in default_config:
			if !config.has(option):
				config[option] = default_config[option]
	
	f.close()
	print(config)

func save_config():
	var f = File.new()
	var err = f.open_encrypted_with_pass("res://config.save", File.WRITE, "Kalammeet")
	f.store_var(config)
	f.close()

func load_game():
	var f = File.new()
	var err = f.open_encrypted_with_pass("res://game_"+str(save)+".save", File.READ, "Kalammeet")
	
	if !err:
		progression = f.get_var()
	
	if progression == null:
		progression = starting_state
	else:
		for option in starting_state:
			if !progression.has(option):
				progression[option] = starting_state[option]
	
	f.close()
	print(progression)

func save_game():
	var f = File.new()
	var err = f.open_encrypted_with_pass("res://game_"+str(save)+".save", File.WRITE, "Kalammeet")
	f.store_var(progression)
	f.close()