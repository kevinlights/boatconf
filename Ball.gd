extends Area

const SPEED = 0.18

export(int) var player_id = 0

var speed_y = 0.5

const SND_SPLASH = preload("res://sounds/splash.ogg")
const Splash = preload("res://Splash.tscn")
const Explosion = preload("res://Explosion.tscn")
onready var world = $".."

func _physics_process(delta):
	speed_y -= 0.02
	translate_object_local(SPEED * Vector3(0, speed_y, -1))
	if translation.y < 0.0:
		Utils.play_sound(translation, SND_SPLASH)
		var splash = Splash.instance()
		splash.translation = translation
		splash.emitting = true
		world.add_child(splash)
		queue_free()

func _body_entered(body):
	if body.get("player_id") == player_id:
		return

	if body.has_method("hit_by_ball"):
		body.hit_by_ball()
		var explosion = Explosion.instance()
		explosion.translation = translation
		explosion.emitting = true
		world.add_child(explosion)
		queue_free()
