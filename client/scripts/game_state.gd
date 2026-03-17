class_name GameState extends RefCounted

## Game State object for TicTacToe++. Tries to be on par with the server-side rust implementation.

var stage := Stage.PreGame
# Jesus
var board: Array[Tile] = [Tile.Empty, Tile.Empty, Tile.Empty, Tile.Empty, Tile.Empty, Tile.Empty, Tile.Empty, Tile.Empty, Tile.Empty]
var active_player_id: int = 0
var players: Dictionary[int, Player]
## History of [member GameEvents].
var history: Array[GameEvent]

enum Stage {
	PreGame,
	InGame,
	Ended,
}

enum Tile {
	Empty,
	Tic,
	Tac,
}

class Player:
	var name: String
	var piece: Tile

func _validate(event: GameEvent) -> bool:
	match event.type:
		GameEvent.GameEventType.PlayerJoined:
			if players.has(event.value["player-id"]):
				return false
		GameEvent.GameEventType.PlayerDisconnected:
			if !players.has(event.value["player-id"]):
				return false
		GameEvent.GameEventType.GameBegin:
			if !players.has(event.value["goes-first"]):
				return false
			if stage != Stage.PreGame:
				return false
		GameEvent.GameEventType.GameEnd:
			stage = Stage.Ended
			var reason: GameEvent.GameEndReason = event.value["reason"]
			match reason:
				GameEvent.GameEndReason.PlayerWon:
					if stage != Stage.InGame:
						return false
				GameEvent.GameEndReason.PlayerLeft:
					pass
		GameEvent.GameEventType.PlaceTile:
			var at: int = event.value["at"]
			var player_id: int = event.value["player-id"]
			if !players.has(player_id):
				return false
			if active_player_id != player_id:
				return false
			if at > 8:
				return false
			if board[at] != Tile.Empty:
				return false
	
	return true

func _consume(event: GameEvent) -> void:
	match event.type:
		GameEvent.GameEventType.PlayerJoined:
			var player_id: int = event.value["player-id"]
			var name: String = event.value["name"]
			var piece: Tile = Tile.Tac if players.size() > 0 else Tile.Tic
			players[player_id] = Player.new()
			players[player_id].name = name
			players[player_id].piece = piece
		GameEvent.GameEventType.PlayerDisconnected:
			var player_id: int = event.value["player-id"]
			players.erase(player_id)
		GameEvent.GameEventType.GameBegin:
			var goes_first: int = event.value["goes-first"]
			active_player_id = goes_first
			stage = Stage.InGame
		GameEvent.GameEventType.GameEnd:
			stage = Stage.Ended
			var reason: String = event.value["reason"]
			match reason:
				"player-left":
					pass
				"player-won":
					pass
		GameEvent.GameEventType.PlaceTile:
			var at: int = event.value["at"]
			var player_id: int = event.value["player-id"]
			board[at] = players[player_id].piece
			for k in players.keys():
				if k != player_id:
					active_player_id = k
			print("Board State: " + str(board))
	
	history.push_back(event)

func dispatch(event: GameEvent) -> bool:
	print_rich("[color=purple]New event:\n\tEventType: %s\n\tEventValue: %s[/color]" % [GameEvent.GameEventType.keys()[event.type], event.value])
	if !_validate(event):
		printerr("Invalid move!")
		return false
		
	_consume(event)
	return true

func determine_winner() -> Tile:
	var row1 = [0, 1, 2]
	var row2 = [3, 4, 5]
	var row3 = [6, 7, 8]
	var col1 = [0, 3, 6]
	var col2 = [1, 4, 7]
	var col3 = [2, 5, 8]
	var diag1 = [0, 4, 8]
	var diag2 = [6, 4, 2]
	
	for arr in [row1, row2, row3, col1, col2, col3, diag1, diag2]:
		var tiles: Array[Tile] = [board[arr[0]], board[arr[1]], board[arr[2]]]
		if _eq_three(tiles[0], tiles[1], tiles[2]):
			return tiles[0]
	
	return Tile.Empty

func _eq_three(a, b, c) -> bool:
	return a == b && a == c && b == c
