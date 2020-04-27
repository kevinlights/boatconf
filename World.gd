extends Node

const SPAWN_POINTS = [
	Vector2(-12, -12),
	Vector2(7, -12),
	Vector2(13, 0),
	Vector2(6, 18),
	Vector2(-11, 12),
	Vector2(-11, 0),
]
const CONTROLS = ["key1", "key2", "joy1", "joy2", "joy3", "joy4"]

const Boat = preload("res://Boat.tscn")

onready var world = $".."

var players = {}
var controls = {}
var spawn_points = []

func _ready():
	randomize()
	reset()

# Sets up the map, wait for players to join
func reset():
	print("RESET")

	# Pause until the game starts
	get_tree().paused = true

	# Delete remaining players
	for child in players.values():
		child = child.get_ref()
		if child:
			child.queue_free()
	players.clear()
	controls.clear()

	# TODO: Create map, pick spawn points
	spawn_points = SPAWN_POINTS

func _process(delta):
	for control in CONTROLS:
		if Input.is_action_just_pressed("%s_fire" % control):
			if not controls.has(control):
				# Player joined, make a boat
				var player_id = len(players)
				print("Player %d joined, %s" % [player_id, control])
				var i = randi() % len(spawn_points)
				var boat = Boat.instance()
				boat.translation = Vector3(spawn_points[i].x, 0.0, spawn_points[i].y)
				boat.player_id = player_id
				boat.control = control
				boat.connect("died", self, "_on_player_lost")
				world.add_child(boat)
				spawn_points.remove(i)
				players[player_id] = weakref(boat)
				controls[control] = player_id

				if len(players) >= 2:
					$StartTimer.start()

# Enough players have joined and timer has elapsed, start
func start_round():
	print("ROUND START")
	get_tree().paused = false

func _on_player_lost(player_id):
	# Keep track of boats, reset on victory
	players.erase(player_id)
	if len(players) <= 1:
		print("Game over")
		$ResetTimer.start()
