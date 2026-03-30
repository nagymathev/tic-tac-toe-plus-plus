class_name GameStateManager extends Node

## Global class responsible for interacting with the GameState and emitting related signals.

var game_state: GameState = GameState.new()

@export var board: Board
@onready var local_mode: LocalModeAPI = $LocalModeAPI
@onready var online_mode: OnlineModeAPI = $OnlineModeAPI

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	board.placed_tile.connect(_on_local_client_placed_tile)
	EventBus.game_restart.connect(_reset.rpc)

func start_local_game() -> void:
	clear_hud()
	if local_mode.start_offline_game() == LocalModeAPI.PeerKind.Host:
		_player_connected_event(1, "HosterMan")
	EventBus.game_started.emit()

func start_online_game() -> void:
	clear_hud()
	if online_mode.start_offline_game() == OnlineModeAPI.PeerKind.Host:
		_player_connected_event(1, "HosterMan")
	EventBus.game_started.emit()

func stop_game() -> void:
	clear_hud()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_reset()

@rpc("authority", "call_local", "reliable")
func _place_tile_event(player_id: int, at: int):
	var event := GameEvent.new()
	event.type = GameEvent.GameEventType.PlaceTile
	event.value = { "player-id": player_id, "at": at }
	if !game_state.dispatch(event):
		return
	
	board.place_tile(at, game_state.players[player_id].piece)
	update_hud()
	
	var winner_piece := game_state.determine_winner()
	print_rich("[color=green]Is there a winner? %s" % GameState.Tile.keys()[winner_piece])
	if winner_piece != GameState.Tile.Empty:
		print_rich("[color=green]Game WON WOOOO")
		for player in game_state.players:
			if game_state.players[player].piece == winner_piece:
				_game_end_event()
	
	if game_state.is_full():
		print_rich("[color=orange]TIE TIE TIE")
		_game_end_event()
	

@rpc("any_peer", "call_local", "reliable")
func send_place_tile_event(at: int) -> void:
	if multiplayer.is_server():
		_place_tile_event.rpc(multiplayer.get_remote_sender_id(), at)

func _game_end_event() -> void:
	var event := GameEvent.new()
	event.type = GameEvent.GameEventType.GameEnd
	event.value = { "reason": GameEvent.GameEndReason.PlayerWon, "value": 1 }
	game_state.dispatch(event)
	
	EventBus.game_ended.emit()

@rpc("authority", "call_local", "reliable")
func _player_connected_event(id: int, name: String) -> void:
	var event := GameEvent.new()
	event.type = GameEvent.GameEventType.PlayerJoined
	event.value = { "player-id": id, "name": name }
	if !game_state.dispatch(event):
		return
	
	if game_state.players.size() == 2:
		var start_event := GameEvent.new()
		event.type = GameEvent.GameEventType.GameBegin
		event.value = { "goes-first": id }
		if game_state.dispatch(event):
			setup_hud()
			EventBus.game_started.emit()

func _on_peer_connected(id: int) -> void:
	print_rich("[color=pink]Peer %s connected!" % id)
	
	# Actually I think it's better if it's just the host that distributes the players
	if multiplayer.is_server():
		# Already connected players
		for player_id in game_state.players:
			print_rich("[color=pink]Sending info about %s to %s" % [player_id, id])
			_player_connected_event.rpc_id(id, player_id, game_state.players[player_id].name)
		_player_connected_event.rpc(id, "Joe")

func _on_peer_disconnected(id: int) -> void:
	if game_state.stage != GameState.Stage.Ended:
		_game_end_event()

@rpc("any_peer", "call_local", "reliable")
func _reset() -> void:
	board.reset()
	game_state = GameState.new()

func setup_hud() -> void:
	%MyPlayer.set_cell_state(game_state.players[multiplayer.get_unique_id()].piece)
	%CurrentPlayer.set_cell_state(game_state.players[game_state.active_player_id].piece)
	
func update_hud() -> void:
	%CurrentPlayer.set_cell_state(game_state.players[game_state.active_player_id].piece)

func clear_hud() -> void:
	%MyPlayer.set_cell_state(GameState.Tile.Empty)
	%CurrentPlayer.set_cell_state(GameState.Tile.Empty)

func _on_local_client_placed_tile(at: int) -> void:
	send_place_tile_event.rpc(at)
