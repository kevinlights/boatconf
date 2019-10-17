extends Spatial

export var player_id = 0

const MAX_SPEED = 0.1
const ACCEL = 0.02
const MAX_TURN_SPEED = 0.02
const TURN_ACCEL = 0.05

onready var world = $".."
var Ball = preload("res://Ball.tscn")

var speed = 0.0
var turn_speed = 0.0
var cooldown = -1.0

func _physics_process(delta):
    # Move forward
    if Input.is_action_pressed("boat%d_forward" % player_id):
        speed = speed * (1.0 - ACCEL) + MAX_SPEED * ACCEL
    else:
        speed = speed * 0.95
    translate_object_local(Vector3(0, 0, -speed))

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
        var ball = Ball.instance()
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
        for i in range(3):
            var ball = Ball.instance()
            ball.transform = transform
            ball.translate_object_local(Vector3(0, 0, -0.8))
            ball.rotate_y(volley * 1.57)
            ball.translate_object_local(Vector3(i - 1, 0, -1.2))
            world.add_child(ball)

    # Cooldown
    cooldown -= delta
