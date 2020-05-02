extends Node

# This is set on a separate node "PlayerManager" instead of World simply so that
# it can run while the World is paused

# Maps the tiles from their binary order to the order in the meshlib
const MAP_TILES = [
	-1, 1, 0, 5, 3, 7, 14, 11,
	2, 13, 4, 12, 6, 9, 10, 8,
]
const CONTROLS = ["key1", "key2", "joy1", "joy2", "joy3", "joy4"]

const Boat = preload("res://Boat.tscn")

onready var world = $".."

var players = {}
var controls = {}
var spawn_points = []
var start_countdown = 0.0

func _ready():
	randomize()
	reset()

# Sets up the map, wait for players to join
func reset():
	print("RESET")

	# Pause until the game starts
	get_tree().paused = true

	# Show title
	$"../Title".visible = true

	# Delete remaining players
	for child in players.values():
		child = child.get_ref()
		if child:
			child.queue_free()
	players.clear()
	controls.clear()

	# Generate random map
	var open_list = {[0, 0]: true}
	var water_tiles = {}
	while len(water_tiles) < 10:
		# Take one position at random from the open list
		var keys = open_list.keys()
		var idx = randi() % len(keys)
		var pos = keys[idx]
		open_list.erase(pos)

		# Mark it as water
		water_tiles[pos] = true

		# Mark neighbors not already water as open
		for rel in [[-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [-1, 1], [1, -1], [1, 1]]:
			var other = [pos[0] + rel[0], pos[1] + rel[1]]
			if not water_tiles.has(other):
				open_list[other] = true

	# Make gridmap
	var map = $"../GridMap"
	map.clear()
	for y in range(-9, 9):
		for x in range(-9, 9):
			var idx = 0
			for i in [[0, 0, 8], [1, 0, 4], [0, 1, 2], [1, 1, 1]]:
				if not water_tiles.has([x + i[0], y + i[1]]):
					idx += i[2]
			map.set_cell_item(x, 0, y, MAP_TILES[idx])

	# Measure map
	var minx = 999
	var maxx = -999
	var miny = 999
	var maxy = -999
	for key in water_tiles.keys():
		minx = min(minx, key[0])
		maxx = max(maxx, key[0])
		miny = min(miny, key[1])
		maxy = max(maxy, key[1])

	# Transform to world coordinates
	var worldmin = map.transform.basis.xform(map.map_to_world(minx, 0, miny) - Vector3(2.5, 0.0, 2.5))
	var worldmax = map.transform.basis.xform(map.map_to_world(maxx, 0, maxy) + Vector3(0.5, 0.0, 0.5))

	# Center camera
	var camera = $"../Camera"
	camera.translation = Vector3(0.5 * (worldmin.x + worldmax.x), 0, 0.62743 * worldmax.z + 0.37257 * worldmin.z)

	# Move camera back
	var diff = max(worldmax.z - worldmin.z, 0.75 * (worldmax.x - worldmin.x))
	camera.translate_object_local(Vector3(0.0, 0.0, 0.627 * diff))

	# Pick spawn points
	spawn_points = []
	for pos in water_tiles.keys():
		pos = map.transform.basis.xform(map.map_to_world(pos[0], 0, pos[1]))
		pos -= Vector3(2.5, 0.0, 2.5)
		pos.y = 0.0
		spawn_points.append(pos)

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		reset()
	if get_tree().paused:
		for control in CONTROLS:
			if Input.is_action_just_pressed("%s_fire" % control):
				if controls.has(control):
					continue
				# Player joined, make a boat
				var player_id = len(players)
				print("Player %d joined, %s" % [player_id, control])
				var i = randi() % len(spawn_points)
				var boat = Boat.instance()
				boat.translation = spawn_points[i]
				boat.player_id = player_id
				boat.control = control
				boat.connect("died", self, "_on_player_lost")
				world.add_child(boat)
				spawn_points.remove(i)
				players[player_id] = weakref(boat)
				controls[control] = player_id

				if len(players) >= 2:
					start_countdown = 3.0

		if len(players) >= 2:
			start_countdown -= delta
			if start_countdown <= 0.0:
				start_round()
			$"../Title/Status".text = "%d players have joined, starting in %.1f" % [len(players), start_countdown]
		else:
			$"../Title/Status".text = "%d players have joined, need 2" % len(players)

# Enough players have joined and timer has elapsed, start
func start_round():
	print("ROUND START")
	$"../Title".visible = false
	get_tree().paused = false

func _on_player_lost(player_id):
	# Keep track of boats, reset on victory
	players.erase(player_id)
	if len(players) <= 1:
		print("Game over")
		$ResetTimer.start()
