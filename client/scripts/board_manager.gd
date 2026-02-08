extends Resource
class_name BoardManager

# Manages the board and it's associated state. It checks for winners and related events.

@export
var empty_field := "-"

@export
var player_one := "X"

@export
var player_two := "O"

## Data for ONE Board
var _map: Array[Array] = []

## Data for several Boards
var _chunks: Array = []

## Populates [param map] according to [param settings]
func _create_map(map: Array[Array], settings: BoardSettings) -> void:
	for y in settings.size_y:
		for x in settings.size_x:
			map[y][x] = empty_field