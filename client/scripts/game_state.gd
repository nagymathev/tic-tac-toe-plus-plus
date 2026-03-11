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

func dispatch(event: GameEvent) -> void:
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
