extends StreamPlayer

export var volume = 0.0
onready var tween = get_node("Tween")

func fade_in(time):
	tween.stop_all()
	tween.interpolate_property(self, "stream/volume_db", -80, volume, time, 0, 1)
	tween.start()
	play()
	set_loop(true)

func fade_out(time):
	tween.stop_all()
	tween.interpolate_property(self, "stream/volume_db", get_volume_db(), -80, time, 0, 1)
	tween.start()
	yield(tween, "tween_complete")
	set_loop(false)
	stop()