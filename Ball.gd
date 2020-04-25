extends Area

const SPEED = 0.18

export(int) var player_id = 0

var speed_y = 0.5

const SFX_SPLASH = preload("res://sounds/splash.ogg")
onready var world = $".."

func _physics_process(delta):
	speed_y -= 0.02
	translate_object_local(SPEED * Vector3(0, speed_y, -1))
	if translation.y < 0.0:
		Utils.play_sound(translation, SFX_SPLASH)
		# TODO: Splash effect
		queue_free()

func _body_entered(body):
	if body.get("player_id") == player_id:
		return

	if body.has_method("hit_by_ball"):
		body.hit_by_ball()
		# TODO: Explosion effect
		queue_free()
