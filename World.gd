extends Spatial

var players = {}

func _ready():
	for child in get_children():
		if child.name.left(4) == 'Boat':
			child.connect("died", self, "_on_player_lost")
			players[child.player_id] = weakref(child)

	#new_round()

func _on_player_lost(player_id):
	players.erase(player_id)
	if len(players) <= 1:
		print("Game over")
		$ResetTimer.start()


func new_round():
	pass
