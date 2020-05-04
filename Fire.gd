extends Spatial

const MAX_PARTICLES = 32

export(float) var badness = 0.0 setget _set_badness

onready var particles = $Particles

func _set_badness(new_badness):
	badness = clamp(new_badness, 0.0, 1.0)
	if not particles:
		return
	if badness < 0.05:
		$Particles.emitting = false
	else:
		$Particles.emitting = true
		$Particles.amount = int(MAX_PARTICLES * badness)

func _ready():
	_set_badness(badness)
