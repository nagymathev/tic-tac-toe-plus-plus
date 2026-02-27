class_name BoardManager extends Node

# # Manages the board and it's associated state. It checks for winners and related events.

var players := ["-", "X", "O"]

enum Player {
	Empty,
	PlayerOne,
	PlayerTwo
}

@export_category("Networking")
@export
var _host := "http://localhost:3000"

## Data for ONE Board
var _map: Array[Array] = []

## Data for several Boards
var _chunks: Array = []

func get_current_player() -> Player:
	var json := await _request_json_from("/currentplayer")
	match json["player"]:
		'-':
			return Player.Empty
		'X':
			return Player.PlayerOne
		'O':
			return Player.PlayerTwo
		_:
			return Player.Empty

func take_turn(player: Player, pos: Vector2) -> void:
	var json := {
		"player": player,
		"posX": pos.x,
		"posY": pos.y
	}
	pass

## Populates [param map] according to [param settings]
func _create_map(map: Array[Array], settings: BoardSettings) -> void:
	for y in settings.size_y:
		for x in settings.size_x:
			map[y][x] = players[0]

## Request JSON from [param url] where url is the part after host.
## Example: "http://localhost:3000/index", the url is: "/index".
func _request_json_from(url: String) -> Dictionary:
	var http := AwaitableHTTPRequest.new()
	add_child(http)
	
	var response := await http.async_request(_host + url)
	if !response.success() or response.status_err():
		push_error("Error with HTTP request.")
	
	print("[BoardManager](_request_json_from) Status Code: ", response.status)
	print("[BoardManager](_request_json_from) Content-Type: ", response.headers["content-type"])
	
	var json := response.body_as_json() as Dictionary
	if not json:
		push_error("JSON Invalid.")
	
	print("[BoardManager](_request_json_from) Full JSON data: ", json)
	return json

# func _ready() -> void:
# 	pass
# 	# _request_json_from("/")
# 	# print(Player.keys()[await get_current_player()])