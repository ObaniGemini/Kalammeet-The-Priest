extends RigidBody2D

var protecting = false
var dodging = false

func damage(damage, side):
	if abs(get_linear_velocity().x) <= 16: 
		set_linear_velocity(Vector2((512+128*damage)*side, 0))