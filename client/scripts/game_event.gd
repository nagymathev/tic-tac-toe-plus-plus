class_name GameEvent extends RefCounted

## GameEvent describes events that can happen throughout the course of the game.[br]
##
## Tries to mimic the server-side GameEvent implementation.[br]
## Examples for each event type:[br]
## [codeblock]
## var place_tile := GameEvent.new()
## place_tile.type = GameEventType.PlaceTile
## place_tile.value = { "player-id": 0,  "at": 7 }
##
## var player_joined := GameEvent.new()
## player_joined.type = GameEventType.PlayerJoined
## player_joined.value = { "player-id": 0, "name": "Bob" }
##
## var player_left := GameEvent.new()
## player_left = GameEventType.PlayerDisconnected
## player_left.value = { "player-id": 0 }
##
## var game_begin := GameEvent.new()
## game_begin = GameEventType.GameBegin
## game_begin.value = { "goes-first": 0 }
##
## var game_end := GameEvent.new()
## game_end = GameEventType.GameEnd
## game_end.value = { "reason": GameEndReason.PlayerWon, "value": 0 }
## [/codeblock]

var type: GameEventType
var value: Dictionary

enum GameEventType {
	PlayerJoined,
	PlayerDisconnected,
	GameBegin,
	GameEnd,
	PlaceTile,
}

enum GameEndReason {
	PlayerLeft,
	PlayerWon,
}
