extends ParallaxBackground

export var offset = 1.0

func _ready():
	set_scale(Vector2(4.5+offset/2, 4.5+offset/2))
	set_process(true)

func _process(delta):
	var o = get_node("../player/Camera2D").get_camera_pos()
	set_offset(Vector2(-o.x, o.y))
	print(get_node("../player/Camera2D").get_camera_pos())