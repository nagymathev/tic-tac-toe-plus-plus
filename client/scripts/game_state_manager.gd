extends Node

## Global class responsible for interacting with the GameState and emitting related signals.

var game_state: GameState = GameState.new()

signal placed_tile(instigator: int, at: int)
signal player_joined(id: int)
signal player_left(id: int)
signal game_won(winner: int)
signal game_begin(goes_first: int)

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

@rpc("authority", "call_local", "reliable")
func _place_tile_event(player_id: int, at: int):
	var event := GameEvent.new()
	event.type = GameEvent.GameEventType.PlaceTile
	event.value = { "player-id": player_id, "at": at }
	game_state.dispatch(event)
	placed_tile.emit(player_id, at)

@rpc("any_peer", "call_local", "reliable")
func send_place_tile_event(at: int) -> void:
	if multiplayer.is_server():
		_place_tile_event.rpc(multiplayer.get_remote_sender_id(), at)

@rpc("authority", "call_local", "reliable")
func _player_connected_event(id: int, name: String) -> void:
	var event := GameEvent.new()
	event.type = GameEvent.GameEventType.PlayerJoined
	event.value = { "player-id": id, "name": name }
	game_state.dispatch(event)
	
	if game_state.players.size() == 2:
		var start_event := GameEvent.new()
		event.type = GameEvent.GameEventType.GameBegin
		event.value = { "goes-first": id }
		if game_state.dispatch(event):
			game_begin.emit(id)

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
	pass
