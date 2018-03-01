extends Node2D

var hovered = false
onready var tween = get_node("Tween")
onready var bg = get_node("bg")

func hover():
	hovered = true
	tween.interpolate_property(bg, "transform/scale", bg.get_scale(), Vector2(864, 352), 0.3, 1, 1)
	tween.start()

func unhover():
	hovered = false
	tween.interpolate_property(bg, "transform/scale", bg.get_scale(), Vector2(0, 352), 0.3, 1, 1)
	tween.start()