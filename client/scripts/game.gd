class_name Game extends Node

## Manages and orchestrates Boards along with it their signals.
## Not concerned with multiplayer that's the GameManager's role.
## This just receives actions and reflects on them.

var server: ClientRenet
var client_id: int
var game_state: GameState
@onready var board: Board = $BoardContainerShadow/Board

func _ready() -> void:
	game_state = GameState.new()
	board.placed_tile.connect(_on_client_placed_tile)

func start_offline_game():
	var thread := Thread.new()
	thread.start(_start_local_server)
	if thread.is_started():
		server = ClientRenet.create_connection("OfflineUser1", "127.0.0.1:8991")
		var dummy = ClientRenet.create_connection("OfflineUser2", "127.0.0.1:8991")
		add_child(dummy)
		server.connected_to_game.connect(_on_connected)
		server.player_joined.connect(_on_player_joined)
		server.player_left.connect(_on_player_left)
		server.placed_tile.connect(_on_placed_tile)
		#add_child(server)
		call_deferred("add_child", server)

func _start_local_server():
	# TODO: have a more flexible server location
	# Exported or not
	if OS.has_feature("editor"):
		OS.execute("../target/debug/server", [])
	else:
		# TODO: server should be bundled with the exported project.
		pass

func start_online_game():
	server = ClientRenet.create_connection("OnlineChad" + str(rand_from_seed(Time.get_ticks_usec())[0]), "127.0.0.1:8991")
	server.connected_to_game.connect(_on_connected)
	server.player_joined.connect(_on_player_joined)
	server.player_left.connect(_on_player_left)
	server.placed_tile.connect(_on_placed_tile)
	add_child(server)

func _on_connected(client_id: int) -> void:
	self.client_id = client_id

func _on_player_joined(client_id: int, username: String) -> void:
	game_state.players[client_id].name = username

func _on_player_left(client_id: int) -> void:
	game_state.players.erase(client_id)

func _on_placed_tile(player_id: int, at: int) -> void:
	board.place_tile(at)

func _on_client_placed_tile(at: int) -> void:
	server.place_tile(at)
