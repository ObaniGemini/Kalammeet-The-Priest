extends Label

func start(damage, pos, group):
	set_text(str(damage))
	set("custom_colors/font_color", Color(1-(damage/500), 1-(damage/500), 0.5-(damage/50)))
	if group == "player":
		set("custom_colors/font_color", Color(1-(damage/500), 0.5-(damage/100), 0.5-(damage/50)))
	
	var start_anim = get_node("AnimationPlayer").get_animation("start").duplicate()
	
	var scale = 1+damage*0.1
	pos = pos+Vector2((randi() % 20 - 10)*64, (randi() % 20 - 10)*64)
	start_anim.track_set_key_value(0, 0, Vector2(scale, scale-0.25))
	start_anim.track_set_key_value(0, 1, Vector2(scale-0.25, scale))
	
	start_anim.track_set_key_value(3, 0, pos+Vector2(damage*(-24), 0))
	start_anim.track_set_key_value(3, 1, pos+Vector2(0, damage*(-24)))
	
	start_anim.track_set_key_value(1, 1, damage*4*(randi() % 3 - 1))
	get_node("AnimationPlayer").remove_animation("start")
	get_node("AnimationPlayer").add_animation("start", start_anim)
	get_node("AnimationPlayer").play("start")
	show()