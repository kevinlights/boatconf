extends Area

const SPEED = 0.18

export(int) var player_id = 0

var speed_y = 1.0

func _physics_process(delta):
	speed_y -= 0.04
	translate_object_local(SPEED * Vector3(0, speed_y, -1))
	if translation.y < 0.0:
		# TODO: Splash effect
		queue_free()

func _body_entered(body):
	if body.get("player_id") == player_id:
		return

	if body.has_method("hit_by_ball"):
		body.hit_by_ball()
		# TODO: Explosion effect
		queue_free()
