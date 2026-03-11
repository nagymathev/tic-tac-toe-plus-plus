class_name BoardData extends Resource

signal game_finished(winner: String)
signal game_restart

var my_player: GameState.Tile:
	get:
		return my_player
	set(value):
		my_player = value
		emit_changed()
var current_player: GameState.Tile:
	get:
		return current_player
	set(value):
		current_player = value
		emit_changed()
