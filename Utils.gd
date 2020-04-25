extends Node

var world = null

func _ready():
	world = get_tree().get_root()

func play_sound(position, stream):
	var sound = AudioStreamPlayer3D.new()
	sound.stream = stream
	sound.translation = position
	sound.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	world.add_child(sound)
	sound.connect("finished", sound, "queue_free")
	sound.play()
