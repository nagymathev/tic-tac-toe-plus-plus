class_name GameEvent extends RefCounted

## GameEvent describes events that can happen throughout the course of the game.[br]
## Tries to mimic the server-side GameEvent implementation.[br]
## Example:[br]
## [codeblock]
## var event := GameEvent.new()
## event.type = GameEventType.PlaceTile
## event.value = { "player-id": 0,  "at": 7 }
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
