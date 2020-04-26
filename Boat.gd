extends KinematicBody

signal died(player_id)

const MAX_SPEED = 5.0
const ACCEL = 0.02
const MAX_TURN_SPEED = 0.02
const TURN_ACCEL = 0.05
const SINK_SPEED = 1.0

export var player_id = 0

var speed = 0.0
var turn_speed = 0.0
var cooldown = -1.0
var health = 5

const Ball = preload("res://Ball.tscn")
const SND_SINGLE = preload("res://sounds/single.ogg")
const SND_VOLLEY = preload("res://sounds/volley.ogg")
const SND_HIT = preload("res://sounds/hit.ogg")
const SND_SINKING = preload("res://sounds/sinking.ogg")
onready var world = $".."

func _physics_process(delta):
	# Sink
	if health <= 0:
		translate(Vector3(0.0, -delta * SINK_SPEED, 0.0))
		return

	# Move forward
	if Input.is_action_pressed("boat%d_forward" % player_id):
		speed = speed * (1.0 - ACCEL) + MAX_SPEED * ACCEL
	else:
		speed = speed * 0.95
	move_and_slide(-speed * global_transform.basis.xform(Vector3(0, 0, 1)), Vector3(0, 1, 0))

	# Turn
	var turn = 0.0
	if Input.is_action_pressed("boat%d_left" % player_id):
		turn += 1.0
	if Input.is_action_pressed("boat%d_right" % player_id):
		turn -= 1.0
	turn = clamp(turn, -1.0, 1.0) * MAX_TURN_SPEED
	turn_speed = turn_speed * (1.0 - TURN_ACCEL) + turn * TURN_ACCEL
	rotate(Vector3(0, 1, 0), turn_speed)

	# Shoot
	if cooldown <= 0.0 and Input.is_action_just_pressed("boat%d_fire" % player_id):
		Utils.play_sound(translation, SND_SINGLE)
		var ball = Ball.instance()
		ball.player_id = player_id
		ball.transform = transform
		ball.translate_object_local(Vector3(0, 0, -3.5))
		world.add_child(ball)
		cooldown = 0.8

	# Volley
	var volley = 0
	if cooldown > 0.0:
		pass
	elif Input.is_action_just_pressed("boat%d_volley_left" % player_id):
		volley = 1
	elif Input.is_action_just_pressed("boat%d_volley_right" % player_id):
		volley = -1
	if volley != 0:
		cooldown = 2.0
		Utils.play_sound(translation, SND_VOLLEY)
		for i in range(3):
			var ball = Ball.instance()
			ball.player_id = player_id
			ball.transform = transform
			ball.translate_object_local(Vector3(0, 0, -0.8))
			ball.rotate_y(volley * 1.57)
			ball.translate_object_local(Vector3(i - 1, 0, -1.2))
			world.add_child(ball)

	# Cooldown
	cooldown -= delta

func hit_by_ball():
	if health <= 0:
		return

	health -= 1
	print("Boat hit, player=%d, health=%d" % [player_id, health])
	Utils.play_sound(translation, SND_HIT)
	if health <= 0:
		emit_signal("died", player_id)
		$SinkTimer.start()
	$Fire.badness = clamp((3 - health) / 3.0, 0.0, 1.0)
