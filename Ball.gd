extends StaticBody

const SPEED = 0.2

func _physics_process(delta):
    translate_object_local(SPEED * Vector3(0, 0, -1))
