extends StaticBody

const SPEED = 0.18

var speed_y = 1.0

func _physics_process(delta):
    speed_y -= 0.04
    translate_object_local(SPEED * Vector3(0, speed_y, -1))
