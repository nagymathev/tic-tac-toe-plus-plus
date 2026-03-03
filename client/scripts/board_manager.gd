class_name BoardManager extends Node

## Manages the board and it's associated state. It checks for winners and related events.

var players := ["_", "X", "O"]

@export_category("Networking")
@export
var _host := "http://localhost:3000"

## UUID for the player given by the server.
var id: String = ""
var player_type := BoardData.PlayerStates.Spectator

func take_turn(pos: Vector2i) -> void:
	var json := {
		"id": id,
		"pos": {
			"x": pos.x,
			"y": pos.y
		}
	}
	_post_json_to("/turn", json)

func register() -> BoardData.PlayerStates:
	var json := await _request_json_from("/register")
	id = json["id"]
	match json["player_type"]:
		"PlayerX":
			player_type = BoardData.PlayerStates.PlayerX
		"PlayerO":
			player_type = BoardData.PlayerStates.PlayerO
		_:
			player_type = BoardData.PlayerStates.Spectator
	print("Successfully registered with id: " + id + "; Assigned Player Type: " + BoardData.PlayerStates.keys()[player_type])
	return player_type

func health_check() -> Dictionary:
	var json := await _request_json_from("/board")
	var board = (json["board"])
	return board


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

func _post_json_to(url: String, data: Dictionary) -> void:
	var http := AwaitableHTTPRequest.new()
	add_child(http)

	var headers := ["Content-Type: application/json"]
	var response := await http.async_request(_host + url, headers, HTTPClient.Method.METHOD_POST, JSON.stringify(data))
	if !response.success() or response.status_err():
		push_error("Error with HTTP request.")

	print("[BoardManager](_post_json_to) Status Code: ", response.status)

# func _ready() -> void:
# 	pass
# 	# _request_json_from("/")
# 	# print(Player.keys()[await get_current_player()])
