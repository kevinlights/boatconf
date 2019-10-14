extends Spatial

export var player_id = 0

const MAX_SPEED = 0.1
const ACCEL = 0.02
const MAX_TURN_SPEED = 0.02
const TURN_ACCEL = 0.05

var speed = 0.0
var turn_speed = 0.0

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
