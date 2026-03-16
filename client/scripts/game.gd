class_name Game extends Node

## Manages and orchestrates Boards along with it their signals.
## Not concerned with multiplayer that's the GameManager's role.
## This just receives actions and reflects on them.

var server: ClientRenet
var client_id: int
var game_state: GameState
@onready var board: Board = $BoardContainerShadow/Board
var local_server_process: Dictionary

#@onready var peer: EOSGMultiplayerPeer = EOSGMultiplayerPeer.new()

func _ready() -> void:
	game_state = GameState.new()
	board.placed_tile.connect(_on_client_placed_tile)
	#peer.peer_connection_closed.connect(_on_peer_connection_closed)
	#peer.peer_connected.connect(_on_peer_connected)
	#peer.peer_disconnected.connect(_on_peer_disconnected)
	#peer.incoming_connection_request.connect(_on_incoming_connection)

func _process(delta: float) -> void:
	#peer.poll()
	#peer.accept_all_connection_requests()
	pass

func start_offline_game():
	_start_local_server()
	server = ClientRenet.create_connection("OfflineUser1", "127.0.0.1:8991")
	_connect_server_signals(server)
	var dummy = ClientRenet.create_connection("OfflineUser2", "127.0.0.1:8991")
	add_child(dummy)
	add_child(server)

func _exit_tree() -> void:
	if local_server_process.has("pid"):
		OS.kill(local_server_process["pid"])

func _start_local_server():
	# TODO: have a more flexible server location
	# Exported or not
	if OS.has_feature("editor"):
		local_server_process = OS.execute_with_pipe("../target/debug/server", [], false)
	else:
		# TODO: server should be bundled with the exported project.
		pass

func start_online_game(settings: OnlineSettings):
	var eos = TTTEOS.new()
	add_child(eos)
	#var nat: EOS.P2P.NATType = await HP2P.get_nat_type_async()
	#print(nat)
	
	#if settings.host:
		#var result := peer.create_server("ttt")
		#if result != OK:
			#printerr("Failed to create servver")
			#return
		#multiplayer.multiplayer_peer = peer
		##_start_local_server()
		##server = ClientRenet.create_connection(settings.username, "127.0.0.1:8991")
	#else:
		#var result := peer.create_client("ttt", settings.username)
		#if result != OK:
			#printerr("FAiled to connect to server")
			#return
		#multiplayer.multiplayer_peer = peer
		#server = ClientRenet.create_connection(settings.username, settings.server_address)
	
	#peer.accept_all_connection_requests()
	#peer.set_auto_accept_connection_requests(true)
	#_connect_server_signals(server)
	#add_child(server)

func _connect_server_signals(server: ClientRenet) -> void:
	server.connected_to_game.connect(_on_connected)
	server.player_joined.connect(_on_player_joined)
	server.player_left.connect(_on_player_left)
	server.placed_tile.connect(_on_placed_tile)
	#server.game_begin.connect(_on_game_begin)

func _on_connected(client_id: int) -> void:
	self.client_id = client_id

func _on_player_joined(client_id: int, username: String) -> void:
	var event = GameEvent.new()
	event.type = GameEvent.GameEventType.PlayerJoined
	event.value = { "player-id": client_id, "name": username }
	game_state.dispatch(event)
	
	if game_state.players.size() == 2:
		var game_begin := GameEvent.new()
		game_begin.type = GameEvent.GameEventType.GameBegin
		game_begin.value = { "goes-first": client_id }
		game_state.dispatch(game_begin)
		_on_game_begin(client_id)
	
	# Displaying info; honsetly should be elsewhere
	# TODO: Reading state and displaying game info should be elsewhere
	var my_cell: BoardCell = %MyPlayer
	if self.client_id == client_id:
		my_cell.set_cell_state(game_state.players[client_id].piece)

func _on_player_left(client_id: int) -> void:
	var event = GameEvent.new()
	event.type = GameEvent.GameEventType.PlayerDisconnected
	event.value = { "player-id": client_id }
	game_state.dispatch(event)

func _on_placed_tile(player_id: int, at: int) -> void:
	var event = GameEvent.new()
	event.type = GameEvent.GameEventType.PlaceTile
	event.value = { "player-id": player_id, "at": at }
	game_state.dispatch(event)
	board.place_tile(at, game_state.players[player_id].piece)
	
	# Displaying info; honsetly should be elsewhere
	# TODO: Reading state and displaying game info should be elsewhere
	var current_player: BoardCell = %CurrentPlayer
	current_player.set_cell_state(game_state.players[game_state.active_player_id].piece)

func _on_game_begin(goes_first: int) -> void:
	# Displaying info; honsetly should be elsewhere
	# TODO: Reading state and displaying game info should be elsewhere
	var current_player: BoardCell = %CurrentPlayer
	current_player.set_cell_state(game_state.players[goes_first].piece)

func _on_client_placed_tile(at: int) -> void:
	server.place_tile(client_id, at)

func _on_peer_connection_closed(data: Dictionary) -> void:
	pass

func _on_peer_connected(id: int) -> void:
	print("Peer connected with id: %s" % id )
	pass

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected with id: %s" % id)
	pass

func _on_incoming_connection(data: Dictionary) -> void:
	print("Incoming connection request!")
	print("Data: %s" % data)
