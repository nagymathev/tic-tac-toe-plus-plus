class_name Game extends Control

## Manages and orchestrates Boards along with it their signals.
## Not concerned with multiplayer that's the GameManager's role.
## This just receives actions and reflects on them.

var client_id: int
@onready var board: Board = $Board
var local_server_process: Dictionary

#func _ready() -> void:
	#board.placed_tile.connect(_on_client_placed_tile)
	#multiplayer.peer_connected.connect(_on_peer_connected)

func start_offline_game():
	print_rich("[color=green]Starting local game![/color]")
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(9099, 2)
	if err != OK:
		print_rich("[color=red]Local server already exists, connecting to it now...[/color]")
		peer.create_client("127.0.0.1", 9099)
	else:
		print_rich("[color=green]Successfully created the server!")
		GameStateManager._player_connected_event(1, "THEGARY") # Necessary for the host, otherwise gets added second
	
	multiplayer.multiplayer_peer = peer

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
	pass


#func _connect_server_signals(server: ClientRenet) -> void:
	#server.connected_to_game.connect(_on_connected)
	#server.player_joined.connect(_on_player_joined)
	#server.player_left.connect(_on_player_left)
	#server.placed_tile.connect(_on_placed_tile)
	#server.game_begin.connect(_on_game_begin)

#func _on_connected(client_id: int) -> void:
	#self.client_id = client_id

#@rpc("any_peer", "call_local", "reliable")
#func player_joined(client_id: int, username: String) -> void:
	#var event = GameEvent.new()
	#event.type = GameEvent.GameEventType.PlayerJoined
	#event.value = { "player-id": client_id, "name": username }
	#if !game_state.dispatch(event):
		#return
	#
	#if game_state.players.size() == 2:
		#var game_begin := GameEvent.new()
		#game_begin.type = GameEvent.GameEventType.GameBegin
		#game_begin.value = { "goes-first": client_id }
		#game_state.dispatch(game_begin)
		#_on_game_begin(client_id)
	
	# Displaying info; honsetly should be elsewhere
	# TODO: Reading state and displaying game info should be elsewhere
	#var my_cell: BoardCell = %MyPlayer
	#if multiplayer.get_unique_id() == client_id:
		#my_cell.set_cell_state(game_state.players[client_id].piece)

#func _on_player_left(client_id: int) -> void:
	#var event = GameEvent.new()
	#event.type = GameEvent.GameEventType.PlayerDisconnected
	#event.value = { "player-id": client_id }
	#game_state.dispatch(event)

#@rpc("any_peer", "call_local", "reliable")
#func _on_placed_tile(player_id: int, at: int) -> void:
	#var event = GameEvent.new()
	#event.type = GameEvent.GameEventType.PlaceTile
	#event.value = { "player-id": player_id, "at": at }
	#if game_state.dispatch(event):
		#board.place_tile(at, game_state.players[player_id].piece)
	#
	## Displaying info; honsetly should be elsewhere
	## TODO: Reading state and displaying game info should be elsewhere
	#var current_player: BoardCell = %CurrentPlayer
	#current_player.set_cell_state(game_state.players[game_state.active_player_id].piece)

#func _on_game_begin(goes_first: int) -> void:
	## Displaying info; honsetly should be elsewhere
	## TODO: Reading state and displaying game info should be elsewhere
	#var current_player: BoardCell = %CurrentPlayer
	#current_player.set_cell_state(game_state.players[goes_first].piece)
#
#func _on_client_placed_tile(at: int) -> void:
	#_on_placed_tile.rpc(multiplayer.get_unique_id(), at)
	##server.place_tile(client_id, at)
#
#func _on_peer_connected(id: int) -> void:
	#player_joined.rpc(id, "User")
