extends Label

func announce(anim, text, color, speed, id):
	if id != -1:
		get_node(str(id)).show()
	set_text(text)
	set("custom_colors/font_color", color)
	get_node("AnimationPlayer").set_speed(speed)
	get_node("AnimationPlayer").play(anim)
	show()